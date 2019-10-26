#!/bin/bash
set -euo pipefail
docker build ./_tmp_liam2_tokengenerator/ -t tmpliam2gt
docker run -p 8044:80 -d tmpliam2gt

