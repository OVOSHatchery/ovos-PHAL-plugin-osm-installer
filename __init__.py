import datetime
import time

import validators
from mycroft.skills.core import (MycroftSkill,
                                 intent_file_handler)
from ovos_skills_manager.github.utils import author_repo_from_github_url
from ovos_skills_manager.osm import OVOSSkillsManager


class OSMInstallerSkill(MycroftSkill):

    def __init__(self):
        super(OSMInstallerSkill, self).__init__(name="OSMInstaller")
        self.osm_manager = OVOSSkillsManager()
        self.osm_manager.enable_appstore("ovos")
        self.osm_manager.enable_appstore("pling")
        self.default_icon = "https://iconarchive.com/download/i103156\
                        /blackvariant/button-ui-requests-9/Parcel.ico"

    def initialize(self):
        self.osm_manager.bind(self.bus)

        self.add_event("OSMInstaller.openvoiceos.home",
                       self.handle_display_home)
        self.add_event("osm.sync.finish",
                       self.update_display_model)
        self.add_event("osm.install.finish", self.display_installer_success)
        self.add_event("osm.install.error", self.display_installer_failure)
        self.gui.register_handler("OSMInstaller.openvoiceos.install",
                                  self.handle_install)

        # Start A Scheduled Event for Syncing OSM data
        now = datetime.datetime.now()
        self.schedule_repeating_event(self.sync_osm_model, now, 9000)

    @intent_file_handler("show-osm.intent")
    def handle_display_home(self, message):
        self.update_display_model()
        self.gui.show_page("AppstoreHome.qml", override_idle=True)

    @intent_file_handler("search-osm.intent")
    def handle_search_osm_intent(self, message):
        utterance = message.data.get("description", "")
        skills = []
        if utterance is not None:
            results = self.osm_manager.search_skills(utterance)
            for s in results:
                skills.append({
                    "title": s.skill_name or s.uuid,
                    "description": s.skill_short_description,
                    "logo": s.json.get(
                        "logo") or s.skill_icon or self.default_icon,
                    "author": s.skill_author,
                    "category": s.skill_category,
                    "url": s.url
                })
            self.gui["appstore_pling_model"] = skills

    # TODO these should be unified into a single method independent of appstore
    # for store in self.osm.appstores .....
    # Build Custom Display Model For OVOS Skill Store
    def build_store_model(self, store_id):
        store = self.osm_manager.get_appstore(store_id)
        skills_model = []
        for skill in store:
            skill_icon = skill.skill_icon or self.default_icon
            if not validators.url(skill.skill_icon):
                # TODO osm should transform the relative paths!
                # discard bad paths for now
                skill_icon = self.default_icon

            author, repo = author_repo_from_github_url(skill.url)
            desc = skill.skill_short_description or \
                   skill.skill_description or \
                   f"{repo} by {author}"
            skills_model.append({
                "title": skill.skill_name or repo,
                "description": desc,
                "logo": skill.json.get("logo") or skill_icon,
                "author": skill.skill_author,
                "category": skill.skill_category,
                "url": skill.url
            })

        return skills_model

    def handle_install(self, message):
        skill_url = message.data.get("url")
        self.gui["installer_status"] = 1  # Running
        self.log.info("Got request to install: " + skill_url)
        try:
            self.osm_manager.install_skill_from_url(skill_url)
        except Exception as e:
            self.log.exception(e)

    def sync_osm_model(self, message):
        self.osm_manager.sync_appstores()

    def update_display_model(self):
        self.gui["installer_status"] = 0  # Idle / Unknown
        self.gui["appstore_ovos_model"] = self.build_store_model("ovos")
        self.gui["appstore_pling_model"] = self.build_store_model("pling")

    def display_installer_success(self, message):
        self.log.info("Installer Successful")
        self.gui["installer_status"] = 2  # Success
        time.sleep(2)
        self.gui["installer_status"] = 0  # Idle / Unknown

    def display_installer_failure(self, message):
        self.log.info("Installer Failed")
        self.gui["installer_status"] = 3  # Fail
        time.sleep(2)
        self.gui["installer_status"] = 0  # Idle / Unknown


def create_skill():
    return OSMInstallerSkill()
