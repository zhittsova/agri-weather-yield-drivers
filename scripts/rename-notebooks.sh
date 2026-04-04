#!/usr/bin/env bash
# rename-notebooks.sh
#
# Adds ordinal prefixes to all notebook filenames via git mv.
#

set -euo pipefail

# GRAY='\e[1;30m'
# YELLOW='\e[1;33m'
# RED='\e[1;31m'
# GREEN='\e[1;32m'
# NC='\e[0m' # No Color

GRAY=$(tput setaf 8)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0)

function rename() {
    # Mapping of renames: from -> to;
    # If "${from[i]}" not exists skip, if "${to[i]}" exists skip; otherwise apply `git mv`:
    local from=(
        "explore-data-sources.ipynb"
        "explore-sandiness-proxies.ipynb"
        "nuts3-duckdb-data-lake.ipynb"
        "eval-dwd-stations-nuts3.ipynb"
        "eval-regionalstatistik-yields.ipynb"
        "eval-dwd-gridded.ipynb"
        "eval-corine-landcover.ipynb"
        "eval-soilgrids-zonal.ipynb"
        "eval-era5-land.ipynb"
        "eval-eobs.ipynb"
        "eval-bgr-buek.ipynb"
        "eval-dwd-phenology.ipynb"
        "eval-esdac.ipynb"
        "ingest-winners.ipynb"
        "validation-coverage-signal.ipynb"
        "analysis-real-data.ipynb"
        "analysis-summary.ipynb"
        "lusatia-lignite-to-solar.ipynb"
        "grid-congestion-drought.ipynb"
        "brandenburg-solar-siting.ipynb"
        "csrd-physical-climate-risk.ipynb"
    )

    local to=(
        "0-explore-data-sources.ipynb"
        "0_5-explore-sandiness-proxies.ipynb"
        "1-nuts3-duckdb-data-lake.ipynb"
        "2_1-eval-dwd-stations-nuts3.ipynb"
        "2_2-eval-regionalstatistik-yields.ipynb"
        "2_3-eval-dwd-gridded.ipynb"
        "2_4-eval-corine-landcover.ipynb"
        "2_5-eval-soilgrids-zonal.ipynb"
        "2_6-eval-era5-land.ipynb"
        "2_7-eval-eobs.ipynb"
        "2_8-eval-bgr-buek.ipynb"
        "2_9-eval-dwd-phenology.ipynb"
        "2_10-eval-esdac.ipynb"
        "3-ingest-winners.ipynb"
        "4-validation-coverage-signal.ipynb"
        "5-analysis-real-data.ipynb"
        "6-analysis-summary.ipynb"
        "lp16-lusatia-lignite-to-solar.ipynb"
        "lp15-grid-congestion-drought.ipynb"
        "lp14-brandenburg-solar-siting.ipynb"
        "adv-csrd-physical-climate-risk.ipynb"
    )

    for i in "${!from[@]}"; do
        if [[ -f "${from[i]}" ]]; then
            if [[ -f "${to[i]}" ]]; then
                echo "${YELLOW}Warning${NC}{$GRAY}: Target file ${to[i]} already exists. Skipping rename of ${from[i]}.${NC}"
            else
                git mv "${from[i]}" "${to[i]}"
                echo "${GREEN}OK${NC}: Renamed ${from[i]} to ${to[i]}."
            fi
        else
            echo "${YELLOW}Warning${NC}${GRAY}: Source file ${from[i]} does not exist. Skipping.${NC}"
        fi
    done
}

cd "$(git rev-parse --show-toplevel)/notebooks"

# if [[ $(git status --porcelain) ]]; then
#     echo "Error: Uncommitted changes detected. Please commit or stash them before running this script."
#     git status --porcelain
#     exit 1
# fi

if [[ -z $(git branch --show-current) ]]; then
    echo "${RED}Error${NC}: Not on a git branch. Please checkout a branch before running this script."
    exit 1
fi

if [[ $(git rev-parse --abrev-ref HEAD) == "main" ]]; then
    echo "${RED}Error${NC}: Currently on main branch. Please checkout a feature branch before running this script."
    exit 1
fi

if [[ $(git rev-parse --abrev-ref HEAD) == "develop" ]]; then
    echo "${RED}Error${NC}: Currently on develop branch. Please checkout a feature branch before running this script."
    exit 1
fi

rename
cd "$(git rev-parse --show-toplevel)/"

echo "Done. Staged renames:"
git status --short
