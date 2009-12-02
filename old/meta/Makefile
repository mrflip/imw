######################################################################
#
# Makefile for infochimps data
#
######################################################################
# utils
map             = $(foreach a,$(2),$(call $(1),$(a)))

SHELL           = /bin/bash

# wehre to put stuff
ICSDIR          = $(HOME)/ics
SITEDIR         = $(ICSDIR)/site
CODEDIR         = $(ICSDIR)/code
DATADIR         = $(ICSDIR)/data
LOADDIR         = $(DATADIR)/load
FIXD            = ./fixd
PKGD            = ./pkgd

ICS_PACK        = rake -f $(CODEDIR)/tools/bin/ics_pack.rb
# Creates the database load files
ICS_DBLOAD	= $(CODEDIR)/tools/bin/ics_dbload.rb
DB_YAML_DUMP    = $(LOADDIR)/tree/ics_schema_dump.yaml


# Get all schemata in the fixd/ tree
#                                   c scCoDS
FIXD_SCHEMATA   = $(wildcard $(FIXD)/*/*/*/*.icss.yaml)
# Strip off all but the cat/subcat/coll/dataset
DATASETS        = $(patsubst $(FIXD)/%.icss.yaml, %, $(FIXD_SCHEMATA))
PKGD_DIRS       = $(patsubst %, $(PKGD)/%,$(DATASETS))
PKGD_SCHEMATA   = $(join $(PKGD_DIRS:=/), $(notdir $(DATASETS:=.icss.yaml)))
PKGD_COLLS	= $(wildcard $(PKGD)/*/*/*)

# # For each dataset, construct a package target
# define PKGDSCH_template
#   # dump onto our list of packages to make
#   PKGD_SCHEMATA += $(PKGD)/$(1)/$(notdir $(1)).icss.yaml
#   # define variables specific to making _this_ package
#   $(PKGD)/$(1)/$(notdir $(1)).icss.yaml: SCHEMA:=$(FIXD)/$(1).icss.yaml
# endef
# $(foreach dataset,$(DATASETS),$(eval $(call PKGDSCH_template,$(dataset))))


.PHONY: all
all:			$(PKGD_DIRS)


# $(PKGD_SCHEMATA): 	$(SCHEMA)
# 	$(ICS_PACK) icss=$(abspath $(SCHEMA))

$(PKGD_DIRS): $(PKGD)/% : $(FIXD)/%.icss.yaml
	$(ICS_PACK) icss=$<
	touch $@


# $(DB_LOAD):		$(PKGD_DIRS)
# 	@echo $(ICS_DBLOAD)

#	KLUDGE -- working around "argument list too long" errors
$(DB_YAML_DUMP):	$(PKGD_DIRS)
	echo "--- "          >  $(DB_YAML_DUMP)
	echo "dumping all schemata into one bigass file"
	echo $(SHELL)
	for coll_dir in $(PKGD_COLLS) ; do cd $(DATADIR)/$$coll_dir ; cat */*.icss.yaml >> $(DB_YAML_DUMP) ; done ; true

.PHONY: db
db:	$(DB_YAML_DUMP)
	$(ICS_DBLOAD)

.PHONY: migrate
migrate: db
	cd $(SITEDIR) ; rake db:migrate VERSION=10 ; rake db:migrate VERSION=99

.PHONY: bigmigrate
bigmigrate: db
	cd $(SITEDIR) ; rake db:migrate:reset

.PHONY: clean
clean: 
        #            c ScCoDsFile
	rm -rf   $(PKGD)/*/*/*/*

######################################################################
#
# debug -- Dump helpful info
#
#######################################################################

.PHONY: debug
debug:
#	$(info $(FIXD_SCHEMATA))
	$(info $(PKGD_SCHEMATA))
#	$(info $(PKGD_DIRS))
#	$(info $(DATASETS))
#	 $(info $(SCHEMA))


# CRUFT:
# 
# map             = $(foreach a,$(2),$(call $(1),$(a)))
# fixdsch_dataset = $(patsubst $(FIXD)/%.icss.yaml, %, $(1))
# pkgdsch_dataset = $(patsubst $(PKGD)/%.icss.yaml, %, $(1))
# dataset_pkgdsch = $(PKGD)/$(1)/$(notdir $(1)).icss.yaml
# dataset_fixdsch = $(FIXD)/$(dir $(1)).icss.yaml
