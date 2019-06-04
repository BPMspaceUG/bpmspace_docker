#!/bin/bash
docker build ./_tmp_liam2_tokengenerator/
docker run -p 8044:80 -d tmpliam2gt

