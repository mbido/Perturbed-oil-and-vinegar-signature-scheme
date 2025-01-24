#!/bin/bash
for file in */*.sage; do
  sage "$file" > /dev/null
  mv "${file}.py" "${file%.sage}.py"
done

# a second time for any interdependencies
for file in */*.sage; do
  sage "$file" > /dev/null
  mv "${file}.py" "${file%.sage}.py"
done