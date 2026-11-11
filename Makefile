.PHONY: all vendor fmt tarball

all: vendor fmt

vendor: .peru/lastimports
	peru reup

fmt: .pre-commit-config.yaml .stylua.toml .styluaignore .editorconfig
	pre-commit run -a

.peru/lastimports: peru.yaml
	peru sync

# Config + installed plugins, laid out relative to $HOME: tar -xzf nvim-lean.tar.gz -C ~
BUILD := .build
tarball:
	rm -rf $(BUILD) && mkdir -p $(BUILD)/.config/nvim
	git ls-files -z | xargs -0 cp --parents -t $(BUILD)/.config/nvim
	XDG_CONFIG_HOME=$(CURDIR)/$(BUILD)/.config XDG_DATA_HOME=$(CURDIR)/$(BUILD)/.local/share \
	XDG_STATE_HOME=$(CURDIR)/$(BUILD)/state XDG_CACHE_HOME=$(CURDIR)/$(BUILD)/cache \
		nvim --headless +qa
	tar -czf nvim-lean.tar.gz -C $(BUILD) --exclude=.git .config .local
