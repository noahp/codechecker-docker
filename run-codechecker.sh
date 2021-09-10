#!/usr/bin/env bash

set -e

CodeChecker check -b "$@" -o ./reports --enable sensitive --ctu
CodeChecker parse ./reports -e html -o ./reports_html
