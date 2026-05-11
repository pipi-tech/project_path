#!/usr/bin/env bash

build_merged() {
  rm -rf overlay/merged/*
  mkdir -p overlay/merged
  cp -r overlay/base/* overlay/merged/ 2>/dev/null
  cp -r overlay/mid/* overlay/merged/ 2>/dev/null
  cp -r overlay/top/* overlay/merged/ 2>/dev/null
}

