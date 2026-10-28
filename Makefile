SKILLS_SOURCE := dwjohnston/agent-skills

.PHONY: skills-add skills-update

# Install the skills from $(SKILLS_SOURCE).
skills-add:
	npx skills add $(SKILLS_SOURCE)

# Update installed skills to their latest versions.
skills-update:
	npx skills update
