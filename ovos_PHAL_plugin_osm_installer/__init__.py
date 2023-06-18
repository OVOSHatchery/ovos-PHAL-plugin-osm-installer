import datetime
import os
from os.path import dirname, join
import time

import validators
from ovos_bus_client.message import Message
from ovos_skills_manager.github.utils import author_repo_from_github_url
from ovos_skills_manager.osm import OVOSSkillsManager
from ovos_plugin_manager.phal import PHALPlugin
from ovos_utils.log import LOG
from ovos_utils.events import EventSchedulerInterface
from ovos_utils.gui import GUIInterface


class OSMInstallerPlugin(PHALPlugin):

    def __init__(self, bus=None, config=None):
        """ Initialize the plugin
            Args:
                bus (MycroftBusClient): The Mycroft bus client
                config (dict): The plugin configuration
        """
        name = "ovos-PHAL-plugin-osm-installer"
        super().__init__(bus=bus, name=name, config=config)
        self.gui = GUIInterface(bus=self.bus, skill_id=name)
        self.osm_manager = OVOSSkillsManager()
        self.osm_manager.enable_appstore("local")
        self.osm_manager.enable_appstore("ovos")
        self._installed_model = None
        self._default_store = "ovos"
        self._current_store = None
        self._previous_store = None
        self._store_update_in_progress = False
        self.default_icon = os.path.join(os.path.dirname(os.path.realpath(__file__)), 
                                         "ui/images/default-package.ico")
        self.esi = EventSchedulerInterface(name=name,
                                           bus=self.bus)

        self.osm_manager.bind(self.bus)
        self.bus.on("osm.installer.show.home",
                       self.handle_display_home)
        self.bus.on("osm.sync.finish",
                       self.update_display_on_sync)
        self.bus.on("osm.store.enabled",
                    self.update_stores_model)
        self.bus.on("osm.store.disabled",
                    self.update_stores_model)
        self.bus.on("osm.install.finish",
                    self.display_installer_success)
        self.bus.on("osm.install.error",
                    self.display_installer_failure)

        # GUI Events
        self.gui.register_handler("osm.installer.dashboard.loaded",
                                  self.handle_dashboard_loaded)
        self.gui.register_handler("osm.installer.close",
                                  self.handle_close)
        self.gui.register_handler("osm.installer.search",
                                  self.handle_search_osm_intent)
        self.gui.register_handler("osm.installer.install",
                                  self.handle_install)
        self.gui.register_handler("osm.installer.uninstall",
                                  self.handle_uninstall)
        self.gui.register_handler("osm.installer.select.display.store",
                                  self.handle_select_display_store)
        self.gui.register_handler("osm.installer.activate.store",
                                  self.handle_activate_store)
        self.gui.register_handler("osm.installer.deactivate.store",
                                  self.handle_deactivate_store)

        # Start A Scheduled Event for Syncing OSM data
        now = datetime.datetime.now()
        self.esi.schedule_repeating_event(
            self.sync_osm_model, now, 9000, name="osm_installer_sync")

    def handle_display_home(self, message):
        self.build_stores_model()
        page = join(dirname(__file__), "ui", "AppstoreHome.qml")
        self.gui.show_page(page, override_idle=True)

    def handle_close(self, message):
        self.gui.release()
        
    def handle_dashboard_loaded(self, message):
        self.update_display_model()

    def handle_search_osm_intent(self, message):
        utterance = message.data.get("description", "")
        skills = []
        if utterance is not None:
            results = self.osm_manager.search_skills(utterance)
            for s in results:
                if s.url not in [x["url"] for x in skills]:
                    skills.append({
                        "title": s.skill_name or s.uuid,
                        "description": s.skill_short_description,
                        "logo": s.json.get(
                            "logo") or s.skill_icon or self.default_icon,
                        "author": s.skill_author,
                        "category": s.skill_category,
                        "url": s.url
                    })
            self.gui["appstore_display_model"] = skills
            
    def build_stores_model(self):
        # Manual entry for known stores since osm doesn't provide a full list
        known_stores = ["local", "ovos", "neon", "pling", "mycroft", "andlo"]
        active_stores = self.osm_manager.get_active_appstores()
        stores_model = {}
        stores_model["all_stores"] = []
        stores_model["active_stores"] = []

        for store in known_stores:
            stores_model["all_stores"].append({
                "store": store,
                "active": store in active_stores.keys()
            })
        
        for store in active_stores:
            stores_model["active_stores"].append({
                "store": store,
                "active": True
            })

        self.gui["default_store"] = self._default_store
        self.gui["appstore_stores_model"] = stores_model
    
    def build_store_display_model(self, store_name):
        self._store_update_in_progress = True
        self._previous_store = self._current_store
        if not store_name == "local":
            self.gui.send_event("osm.installer.display.store.change.started")

        store = self.osm_manager.get_appstore(store_name)
        skills_model = []
        for skill in store:
            skill_icon = skill.skill_icon or self.default_icon
            if not validators.url(skill.skill_icon):
                #TODO osm should transform the relative paths!
                #discard bad paths for now
                skill_icon = self.default_icon

            author, repo = author_repo_from_github_url(skill.url)
            desc = skill.skill_short_description or \
                   skill.skill_description or \
                   f"{repo} by {author}"

            if self._installed_model:
                installed = self.check_local_for_install(skill.url)
            else:
                installed = False

            if not any(s["url"] == skill.url for s in skills_model):
                skills_model.append({
                    "title": skill.skill_name or repo,
                    "description": desc,
                    "logo": skill.json.get("logo") or skill_icon,
                    "author": skill.skill_author,
                    "category": skill.skill_category,
                    "url": skill.url,
                    "installed": installed
                })

        if not store_name == "local":
            self._current_store = store_name
            self.gui.send_event("osm.installer.display.store.changed", {"store": str(self._current_store)})
            self.gui.send_event("osm.installer.display.store.change.finished")

        self._store_update_in_progress = False
        return skills_model

    def handle_install(self, message):
        skill_url = message.data.get("url")
        self.gui["installer_status"] = 1  # Running
        try:
            self.osm_manager.install_skill_from_url(skill_url)
        except Exception as e:
            self.log.exception(e)
            
    def handle_uninstall(self, message):
        self.log.debug("Got request to uninstall: " + message.data.get("url"))
        #TODO: OSM doesn't support uninstalling yet
        
    def handle_activate_store(self, message):
        self.log.debug("Activating Store: " + message.data.get("store"))
        self.osm_manager.enable_appstore(message.data.get("store"))
        self.gui.send_event("osm.installer.stores.model.updating")
        
    def handle_deactivate_store(self, message):
        self.log.debug("Deactivating Store: " + message.data.get("store"))
        self.osm_manager.disable_appstore(message.data.get("store"))
        self.gui.send_event("osm.installer.stores.model.updating")
        if not self._previous_store == message.data.get("store"):
            self.handle_select_display_store(Message("osm.installer.select.display.store",
                                                 {"store": self._previous_store}))
        else:
            self.handle_select_display_store(Message("osm.installer.select.display.store",
                                                    {"store": self._default_store}))

    def handle_select_display_store(self, message):
        store = message.data.get("store")
        if not self._store_update_in_progress:
            self.gui["appstore_display_model"] = self.build_store_display_model(store)

    def sync_osm_model(self, message=None):
        self.osm_manager.sync_appstores()

    def check_local_for_install(self, url):
        for skill in self._installed_model:
            if skill["url"] == url:
                return True
        return False
    
    def update_stores_model(self, message):        
        self.build_stores_model()
        self.gui.send_event("osm.installer.stores.model.updated")
        self.sync_osm_model()
    
    def update_display_on_sync(self, message):
        if not self._store_update_in_progress:
            self.update_display_model()

    def update_display_model(self, message=None):
        self.gui["installer_status"] = 0 # Idle / Unknown
        self._installed_model = self.build_store_display_model("local")
        if not self._current_store:
            self.handle_select_display_store(
                Message("osm.installer.select.display.store", {"store": self._default_store}))
        else:
            self.handle_select_display_store(
                Message("osm.installer.select.display.store", {"store": self._current_store}))

    def display_installer_success(self, message):
        self.gui["installer_status"] = 2  # Success
        time.sleep(2)
        self.gui["installer_status"] = 0  # Idle / Unknown

    def display_installer_failure(self, message):
        self.gui["installer_status"] = 3  # Fail
        time.sleep(2)
        self.gui["installer_status"] = 0  # Idle / Unknown

    def shutdown(self):
        self.esi.cancel_scheduled_event("osm_installer_sync")
        self.bus.remove("osm.installer.show.home",
                        self.handle_display_home)
        self.bus.remove("osm.sync.finish",
                        self.update_display_on_sync)
        self.bus.remove("osm.store.enabled",
                        self.update_stores_model)
        self.bus.remove("osm.store.disabled",
                        self.update_stores_model)
        self.bus.remove("osm.install.finish",
                        self.display_installer_success)
        self.bus.remove("osm.install.error",
                        self.display_installer_failure)
        super().shutdown()
