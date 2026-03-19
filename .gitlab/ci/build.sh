#!/usr/bin/env bash

# SPDX-License-Identifier: AGPL-3.0

#    ---------------------------------------------------------------
#    Copyright © 2022, 2023, 2024, 2025, 2026
#              Pellegrino Prevete
#
#    All rights reserved
#    ---------------------------------------------------------------
#
#    This program is free software: you can redistribute it
#    and/or modify it under the terms of the GNU Affero
#    General Public License as published by the Free Software
#    Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General
#    Public License along with this program.
#    If not, see <https://www.gnu.org/licenses/>.


# This script is run within a virtual environment to build
# the package
# $1: platform
# $2: architecture
# $3: namespace
# $4: package
# $5: (optional) project-id
# $6: (optional) commit
# $7: (optional) tag
# $8: (optional) ci-job-token
# $9: (optional) package-registry-url

set \
  -euo \
    pipefail
shopt \
  -s \
    extglob

_gur_mini() {
  local \
    _ns="${1}" \
    _pkg="${2}" \
    _release="${3}" \
    _depends_skip \
    _pacman_opts=() \
    _api \
    _url \
    _msg=() \
    _sig
  _depends_skip="y"
  if (( 3 < "${#}" )); then
    _depends_skip="${4}"
  fi
  _msg=(
    "Downloading '${_pkg}'"
    "binary CI release"
    "from '${_ns}' namespace"
    "Gitlab.com."
  )
  echo \
    "${_msg[*]}"
  _gl_dl_retrieve \
    "https://gitlab.com/api/v4/projects/${_ns}%2F${_pkg}-ur"
  _project_id="$(
    cat \
      "${HOME}/${_ns}%2F${_pkg}-ur" | \
      jq \
        '.id')"
  if [[ "${_project_id}" == "null" ]]; then
    _msg=(
      "The project '${_pkg}-ur' does not exist"
      "in namespace '${_ns}'."
    )
    echo \
      "${_msg[*]}"
    return \
      1
  fi
  _api="https://gitlab.com/api/v4"
  _url="${_api}/projects/${_project_id}/releases"
  _gl_dl_retrieve \
    "${_url}"
  _urls=( $(
    cat \
      "${HOME}/releases" | \
      jq \
        '.[0].assets.links.[]' | \
        jq \
          --raw-output \
          '.direct_asset_url')
  )
  for _url in "${_urls[@]}"; do
    _file="$(
      basename \
        "${_url}")"
    _output_file="$(pwd)/${_file}"
    _gl_dl_retrieve \
      "${_url}"
  done
  for _sig in "${HOME}/"*".pkg.tar.xz.sig"; do
    gpg \
      --verify \
        "${_sig}"
  done
  rm \
    -rf \
    "${HOME}/"*".pkg.tar.xz.sig"
  _pacman_opts+=(
    -U
  )
  if [[ "${_depends_skip}" == "y" ]]; then
    _pacman_opts+=(
      -dd
    )
  fi
  _pacman_opts+=(
    --noconfirm
  )
  pacman \
    "${_pacman_opts[@]}" \
    "${HOME}/"*".pkg.tar.xz"
}

_fur_mini() {
  local \
    _pkg="${1}" \
    _platform="${2}" \
    _clone_opts=() \
    _mktemp_opts=() \
    _orig_pwd \
    _tmp_dir \
    _tmp_dir_base
  _orig_pwd="${PWD}"
  _tmp_dir_base="${_orig_pwd}/tmp"
  _mktemp_opts+=(
    --dry-run
    --directory
    --tmpdir="${_tmp_dir_base}"
  )
  _clone_opts+=(
    --branch="${_pkg}"
    --single-branch
    --depth=1
  )
  _tmp_dir="$(
    mktemp \
      "${_mktemp_opts[@]}")"
  git \
    clone \
      "${_clone_opts[@]}" \
      "https://github.com/themartiancompany/fur" \
      "${_tmp_dir}/fur"
  rm \
    -rf \
    "${_tmp_dir}/fur/${_platform}/"*"/"*".pkg.tar.xz.sig"
  pacman \
    -Udd \
    --noconfirm \
    "${_tmp_dir}/fur/${_platform}/"*"/"*".pkg.tar.xz"
  rm \
    -rf \
    "${_tmp_dir}/fur"
}

_check_tag_latest() {
  local \
    _pkgname="${1}" \
    _msg=() \
    _tag \
    _tag_build \
    _tag_current \
    _tag_recipe \
    _repo_dir
  _repo_dir="/home/user/${_pkgname}"
  git \
    config \
      --global \
      --add \
        "safe.directory" \
        "${_repo_dir}"
  _tag="$(
    git \
      -C \
        "${_repo_dir}" \
      tag |
      sort \
        -V |
        tail \
          -n \
            1)"
  _tag_build="${tag}"
  _tag_current="${_tag_build}"
  _tag_recipe="$(
    recipe-get \
      "${_repo_dir}/PKGBUILD" \
      "pkgver" || \
      true)-$(
        recipe-get \
          "${_repo_dir}/PKGBUILD" \
          "pkgrel")"
  _tag_current="${_tag_recipe}"
  if [[ "${_tag}" != "${_tag_current}" ]]; then
    _msg=(
      "Current build tag '${_tag_current}',"
      "latest tag '${_tag}'."
    )
    echo \
      "${_msg[*]}"
    exit \
      0
  fi
}

_requirements() {
  local \
    _fur_mini_opts=() \
    _fur_opts=() \
    _pkgname \
    _pkgver \
    _commit \
    _docs_commit \
    _git_http \
    _evm_chains_release_latest \
    _evm_chains_explorers_release_latest \
    _evm_chains_info_release_latest \
    _evm_contracts_abi_get_release_latest \
    _evm_contracts_tools_release_latest \
    _evm_gnupg_release_latest \
    _evm_wallet_release_latest \
    _fur_release_latest \
    _fur_release_public \
    _gl_dl_release_latest \
    _gur_release_latest \
    _libcrash_bash_release_latest \
    _libcrash_js_release_latest \
    _node_run_release_latest \
    _python_asyncio_throttle_release_latest \
    _python_aioetherscan_release_latest \
    _python_aiohttp_retry_release_latest
  _pkgname="${pkg%-ur}"
  _fur_mini_opts+=(
    "${platform}"
  )
  _fur_mini \
    "libcrash-bash" \
    "${_fur_mini_opts[@]}"
  _fur_mini \
    "fur" \
    "${_fur_mini_opts[@]}"
  _fur_release_public="0.0.1.1.1.1.1.1.1.1.1.1.1"
  # _fur_opts+=(
  #   -v
  #   -p
  #     "pacman"
  # )
  # pacman \
  #   -S \
  #   --noconfirm \
  #   "sudo"
  _gur_mini \
    "${ns}" \
    "reallymakepkg" \
    "1.2.5-1" || \
  true
  _check_tag_latest \
    "${_pkgname}"
  _evm_chains_release_latest="20250816-6"
  _evm_chains_explorers_release_latest="0.0.0.0.0.0.0.0.0.0.1.1.1-5"
  _evm_chains_info_release_latest="0.0.0.0.0.0.0.0.0.0.1.1.1.1.1.1.1-8"
  _evm_contracts_abi_get_release_latest="0.0.0.0.0.0.0.0.0.0.0.1.1.1.1.1.1-3"
  _evm_contract_tools_release_latest="0.0.0.0.0.0.0.0.1.1.1.1.1-4"
  _evm_gnupg_release_latest="0.0.0.0.0.0.0.0.1.1.1.1.1.1-5"
  _evm_wallet_release_latest="0.0.0.0.0.0.0.0.0.0.1.1.1-7"
  _fur_release_latest="1.0.0.0.0.0.0.0.0.0.1.1-2"
  _gl_dl_release_latest="0.0.0.0.0.0.0.0.0.0.0.0.1.1.1.1.1.1-5"
  _gur_release_latest="0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.1-9"
  _key_gen_release_latest="0.0.0.0.0.0.0.0.0.0.0.1-5"
  _libcrash_bash_release_latest="0.0.0.0.0.1.1.1.1.1-11"
  _libcrash_js_release_latest="0.1.69-25"
  _libevm_release_latest="0.0.0.0.0.0.0.0.1.1.1.1.1.1.1-4"
  _node_run_release_latest="0.0.0.0.0.0.0.0.1-10"
  _python_aiohttp_retry_release_latest="2.8.3-7"
  _python_aioetherscan_release_latest="0.9.6.1-9"
  _python_asyncio_throttle_release_latest="1.0.2-9"
  _ucantellme_release_latest="0.0.0.0.0.0.0.0.0.0.0.0.0.1.1.1-3"
  _gur_mini \
    "${ns}" \
    "libcrash-bash" \
    "${_libcrash_bash_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "libcrash-js" \
    "${_libcrash_js_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "node-run" \
    "${_node_run_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "gl-dl" \
    "${_gl_dl_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "ucantellme" \
    "${_ucantellme_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "key-gen" \
    "${_key_gen_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-chains" \
    "${_evm_chains_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-chains-explorers" \
    "${_evm_chains_explorers_release_latest}" \
    "n" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-chains-info" \
    "${_evm_chains_info_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "libevm" \
    "${_libevm_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "python-asyncio-throttle" \
    "${_python_asyncio_throttle_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "python-aiohttp-retry" \
    "${_python_aiohttp_retry_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "python-aioetherscan" \
    "${_python_aioetherscan_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-contracts-abi-get" \
    "${_evm_contracts_abi_get_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-wallet" \
    "${_evm_wallet_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-contracts-tools" \
    "${_evm_contract_tools_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "evm-gnupg" \
    "${_evm_gnupg_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "gur" \
    "${_gur_release_latest}" || \
  true
  _gur_mini \
    "${ns}" \
    "fur" \
    "${_fur_release_latest}" || \
  true
  pacman \
    -S \
    --noconfirm \
    "tree" \
    "github-cli" \
    "unzip"
  # _fur_opts+=(
  #   -l
  #     "bur"
  #   -m
  #     "gitlab"
  # )
  # fur \
  #   "${_fur_opts[@]}" \
  #   "gur"
  # _fur_opts+=(
  #   -t
  #     "ci"
  # )
  # fur \
  #   "${_fur_opts[@]}" \
  #   "reallymakepkg"
  _git_http="$(
    recipe-get \
      "/home/user/${_pkgname}/PKGBUILD" \
      "_git_http" || \
      true)"
  # ohoh
  if [[ "${_git_http}" == "gitlab" ]]; then
    _commit="$(
      recipe-get \
        "/home/user/${_pkgname}/PKGBUILD" \
        "_commit")"
    _gl_dl_mini \
      "${ns}" \
      "${_pkgname}" \
      "${_commit}"
    cp \
      "${HOME}/${_pkgname}-${_commit}.tar.gz" \
      "/home/user/${_pkgname}"
  else
    echo \
      "Direct download in the PKGBUILD"
  fi
}

_build() {
  local \
    _reallymakepkg_opts=() \
    _makepkg_opts=() \
    _makedepends=() \
    _cmd=() \
    _depend \
    _depend_name \
    _depend_pkgver \
    _depend_target \
    _home \
    _oldpwd \
    _node_available \
    _pacman_opts=() \
    _pkgbuild \
    _pkgname \
    _resolve_flag \
    _work_dir \
    _separators=() \
    _msg=()
  declare \
    -A \
    _makedepends_set
  _separators=(
    "<"
    ">"
    "<="
    ">="
    "="
  )
  _home="/home/user"
  _pkgname="${pkg%-ur}"
  _work_dir="${_home}/${_pkgname}-build"
  _pkgbuild="${_home}/${_pkgname}/PKGBUILD"
  _ramdisk_enabled="$(
    mount |
      grep \
        "${_home}/ramdisk" || \
      true)"
  if [[ "${_ramdisk_enabled}" != "" ]]; then
    _work_dir="${_home}/ramdisk/${_pkgname}-build"
  fi
  _reallymakepkg_opts+=(
    -v
    -w
      "${_work_dir}"
  )
  _makepkg_opts+=(
    -d
    -f
    --nocheck
  )
  if [[ "${ns}" != "themartiancompany" ]]; then
    _evmfs="$(
      recipe-get \
        "/home/user/${_pkgname}/PKGBUILD" \
        "_evmfs")"
    if [[ "${_evmfs}" == "false" ]]; then
      _makepkg_opts+=(
        --skipinteg
      )
    fi
  fi
  for _depend \
    in $(recipe-get \
           "${_pkgbuild}" \
           "makedepends"); do
    _resolve_flag="false"
    _depend_target="${_depend}"
    for _sep in "${_separators[@]}"; do
      if [[ "${_depend}" == *"${_sep}"* ]]; then
        _depend_name="${_depend%${_sep}*}"
        _depend_pkgver="${_depend#${_depend_name}}"
        _resolve_flag="true"
        _depend_target="${_depend_name}"
        break
      fi
    done
    if [[ "${_resolve_flag}" == "true" ]]; then
      _msg=(
        "It is requested version"
        "'${_depend_pkgver}' of"
        "package '${_depend_name}'."
        "Be aware the Fur doesn't"
        "look for provides currently."
      )
      echo \
        "${_msg[*]}"
    fi
    _makedepends_set["${_depend_target}"]="1"
  done
  _makedepends=(
      "${!_makedepends_set[@]}"
  )
  _fur_opts+=(
    -v
    -p
      "pacman"
  )
  _msg=(
    "Found makedepends"
    "'${_makedepends[*]}'."
  )
  echo \
    "${_msg[*]}"
  for _depend in "${_makedepends[@]}"; do
    _msg=(
      "Installing makedepend"
      "'${_depend}'"
      "with pacman."
    )
    echo \
      "${_msg[*]}"
    _pacman_opts=(
      -S
      --noconfirm
    )
    if [[ "${_depend}" == "nodejs-lts"* ]]; then
      _node_available="$(
        ( pacman \
            -Q \
            "nodejs" \
            2>"/dev/null" ) |
          grep \
            "^Name\b" |
          awk \
            -F \
              ":" \
            '{print $2}' \
          2>/dev/null)"
      if [[ "${_node_available}" == "nodejs" ]]; then
        _pacman_opts+=(
          --ask
            4
          -dd
        )
        _msg=(
          "A specific version of Node.js"
          "LTS is required as a dependency."
          "That's ill-posed, as if a specific"
          "package version does require a specific"
          "version of Node then it should request"
          "that version and not just simply"
          "a 'latest - N' version because"
          "that's not a version it's a tag."
          "So more or less somebody should produce"
          "not even 'nodejs-lts-jod' but simply"
          "'nodejsXY' and require it in the package."
        )
        echo \
          "${_msg[*]}"
      elif [[ "${_node_available}" == "nodejs-lts"* ]]; then
        _msg=(
          "Node.js LTS installed."
        )
        echo \
          "${_msg[*]}"
      fi
    fi
    pacman \
      -S \
      --noconfirm \
        "${_depend}" || \
      true
    _msg=(
      "Installing makedepends"
      "'${_depend}' with"
      "fur."
    )
    echo \
      "${_msg[*]}"
    fur \
      "${_fur_opts[@]}" \
      -t \
        "ci" \
      -n \
        "${ns}" \
      "${_depend}" || \
    fur \
      "${_fur_opts[@]}" \
      -t \
        "tree" \
      -m \
        "gitlab" \
      -l \
        "bur" \
      "${_depend}" || \
    fur \
      "${_fur_opts[@]}" \
      -t \
        "tree" \
      -m \
        "github" \
      -l \
        "fur" \
      "${_depend}" || \
    true
  done
  _cmd+=(
    "cd"
      "${_home}/${_pkgname}" "&&"
  )
  _git_http="$(
    recipe-get \
      "/home/user/${_pkgname}/PKGBUILD" \
      "_git_http" || \
      true)"
  if [[ "${_git_http}" == "gitlab" ]]; then
    _cmd+=(
      "_ns='${ns}'"
    )
  fi
  _cmd+=(
    "reallymakepkg"
      "${_reallymakepkg_opts[@]}"
      "--"
      "${_makepkg_opts[@]}"
  )
  su \
    -c \
    "${_cmd[*]}" - \
    "user" || \
  true
  _something_built="false"
  for _file in "${_home}/${_pkgname}/"*".pkg.tar."*; do
    _something_built="true"
    break
  done
  if [[ "${_something_built}" == "true" ]]; then
    pacman \
      -Udd \
      --noconfirm \
      "${_home}/${_pkgname}/"*".pkg.tar."*
  elif [[ "${_something_built}" == "false" ]]; then
    _msg=(
      "Build failed, printing"
      "work directory content."
    )
    echo \
      "${_msg[*]}"
    tree \
      -L 2 \
      "${_work_dir}"
    _oldpwd="${PWD}"
    cd \
      "${_work_dir}"
    tar \
      cJf \
      "build-directory.tar.xz" \
      *
    mv \
      "build-directory.tar.xz" \
      "${_oldpwd}"
    cd \
      "${_oldpwd}"
  fi
  for _file \
    in "${_home}/${_pkgname}/"*".pkg.tar."*; do
    mv \
      "${_file}" \
      "dogeos-gnu-$(
        basename \
          "${_file}")"
  done
  for _file \
    in "./"*".pkg.tar."*; do
    gpg \
      --sign \
      --detach-sign \
      "${_file}"
  done
}

_gl_dl_mini() {
  local \
    _ns="${1}" \
    _pkg="${2}" \
    _commit="${3}" \
    _url \
    _http \
    _repo \
    _tarname \
    _msg=()
  _tarname="${_pkg}-${_commit}"
  _http="https://gitlab.com"
  _repo="${_http}/${_ns}/${_pkg}"
  _url="${_repo}/-/archive/${_commit}/${_tarname}.tar.gz"
  _msg=(
    "Downloading '${_tarname}'"
    "source tarball from"
    "'${_ns}' namespace on"
    "Gitlab.com."
  )
  echo \
    "${_msg[*]}"
  _gl_dl_retrieve \
    "${_url}"
}

_gl_dl_retrieve() {
  local \
    _url="${1}" \
    _token_private \
    _token \
    _curl_opts=() \
    _output_file \
    _msg=() \
    _token_missing
  _output_file="${HOME}/$(
    basename \
      "${_url#https://}")"
  _token_private="${HOME}/.config/gitlab.com/default.txt"
  _token_missing="false"
  if [[ ! -e "${_token_private}" ]]; then
    _token_missing="true"
  elif [[ -e "${_token_private}" ]]; then
    if [[ "$(cat "${_token_private}")" == ""  ]]; then
      _token_missing="true"
    fi
  fi
  if [[ "${_token_missing}" == "true" ]]; then
    _msg=(
      "Missing private token at"
      "'${_token_private}'."
    )
    echo \
      "${_msg[*]}"
    _msg=(
      "Set the 'GL_DL_PRIVATE_TOKEN'"
      "variable in your Gitlab.com" \
      "CI namespace or repository configuration."
    )
    echo \
      "${_msg[*]}"
    exit \
      1
  fi
  _token="PRIVATE-TOKEN: $(
    cat \
      "${_token_private}")"
  _curl_opts+=(
    --silent
    -L
    --header
      "${_token}"
    -o 
      "${_output_file}"
  )
  _msg=(
    "Downloading '${_url}'."
  )
  echo \
    "${_msg[*]}"
  curl \
    "${_curl_opts[@]}" \
    "${_url}"
}

_mem_free_get() {
  free | \
    grep \
      "Mem:" | \
    awk \
      '{print $4}'
}

_show_config() {
  _mem_free="$(
    _mem_free_get)"
  echo \
    "Free memory: '${_mem_free}'"
  mount | \
    grep \
      "/home/user/ramdisk"
  inxi \
    -e
  du \
    -hs \
      /usr
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

_requirements
_show_config
_build

# vim:set sw=2 sts=-1 et:
