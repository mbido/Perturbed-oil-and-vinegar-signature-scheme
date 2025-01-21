#!/bin/bash
cd src
for file in *.sage; do
  sage "$file" > /dev/null
  mv "${file}.py" "${file%.sage}.py"
done