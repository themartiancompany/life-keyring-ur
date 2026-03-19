#!/usr/bin/env bash

# SPDX-License-Identifier: AGPL-3.0

#    ----------------------------------------------------------------------
#    Copyright © 2022, 2023, 2024, 2025  Pellegrino Prevete
#
#    All rights reserved
#    ----------------------------------------------------------------------
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


# This script is run within a virtual environment to build
#  pakcage
# $1: platform
# $2: architecture

set \
  -euo \
    pipefail
shopt \
  -s \
    extglob

_gl_dl_upload() {
  local \
    _input_file="${1}" \
    _url="${2}" \
    _token_private \
    _token \
    _curl_opts=() \
    _msg=()
  _token_private="${HOME}/.config/gitlab.com/default.txt"
  if [[ ! -e "${_token_private}" ]]; then
    _msg=(
      "Missing private token at"
      "'${_token_private}'."
    )
    echo \
      "${_msg[*]}"
    _msg=(
      "Set the 'GL_DL_PRIVATE_TOKEN'"
      "variable in your Gitlab.com" \
      "CI namespace configuration."
    )
    echo \
      "${_msg[*]}"
  fi
  _token="PRIVATE-TOKEN: $( \
    cat \
      "${_token_private}")"
  _curl_opts+=(
    --silent
    -L
    --header
      "${_token}"
    --upload-file 
      "${_input_file}"
  )
  _msg=(
    "Uploading '${_input_file}'"
    "at URL '${_url}'."
  )
  echo \
    "${_msg[*]}"
  curl \
    "${_curl_opts[@]}" \
    "${_url}"
}

_upload() {
  local \
    _assets_links_json=() \
    _assets_link \
    _curl_opts=() \
    _release_cli_create_opts=() \
    _msg=() \
    _pkgname
  _pkgname="${pkg%-ur}"
  pwd
  ls
  for _file \
    in "dogeos-"*".pkg.tar."*; do
    _url="${package_registry_url}/${_pkgname}/${tag}/${_file}"
    _gl_dl_upload \
      "$(pwd)/${_file}" \
      "${_url}"
    _asset_link="{$( \
      printf \
      '"name":"'${_file}'","url":"'${_url}'"}')"
    _assets_links_json+=(
      "${_asset_link}"
    )
  done
  _assets_link="$( \
    printf \
      '%s,' \
      "${_assets_links_json[@]}")"
  _assets_link="[${_assets_link::-1}]"
  _release_cli_create_opts+=(
    --name
      "Release: ${tag}"
    --tag-name
      "${tag}"
  )
  _msg=(
    "Running 'release-cli'"
    "with options"
    "create"
    "'${_release_cli_create_opts[*]} --assets-link=${_assets_link}'."
  )
  echo \
    "${_msg[*]}"
  release-cli \
    --debug \
    create \
    "${_release_cli_create_opts[@]}" \
    --assets-link="${_assets_link}"
}

readonly \
  platform="${1}" \
  arch="${2}" \
  ns="${3}" \
  pkg="${4}" \
  project_id="${5}"
if (( 5 < "${#}" )); then
  commit="${6}"
fi
if (( 6 < "${#}" )); then
  tag="${7}"
fi
if (( 7 < "${#}" )); then
  ci_job_token="${8}"
fi
if (( 8 < "${#}" )); then
  package_registry_url="${9}"
fi

_upload

# vim:set sw=2 sts=-1 et:
