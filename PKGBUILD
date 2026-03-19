# SPDX-License-Identifier: AGPL-3.0

#    ----------------------------------------------------------------------
#    Copyright © 2024, 2025, 2026  Pellegrino Prevete
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

# Maintainers:
#   Truocolo
#     <truocolo@aol.com>
#     <truocolo@0x6E5163fC4BFc1511Dbe06bB605cc14a3e462332b>
#   Pellegrino Prevete (dvorak)
#     <pellegrinoprevete@gmail.com>
#     <dvorak@0x87003Bd6C074C713783df04f36517451fF34CBEf>
# Contributors:
#   Pierre Schmitz
#     <pierre@archlinux.de>
#   Bartłomiej Piotrowski
#     <bpiotrowski@archlinux.org>

_evmfs_available="$(
  command \
    -v \
    "evmfs" || \
    true)"
if [[ ! -v "_evmfs" ]]; then
  if [[ "${_evmfs_available}" != "" ]]; then
    _evmfs="true"
  elif [[ "${_evmfs_available}" == "" ]]; then
    _evmfs="false"
  fi
fi
_os="$(
  uname \
    -o)"
if [[ ! -v "_offline" ]]; then
  _offline="true"
fi
if [[ ! -v "_git" ]]; then
  _git="false"
fi
if [[ ! -v "_git_service" ]]; then
  _git_service="gitlab"
fi
if [[ ! -v "_git_http" ]]; then
  _git_http="${_git_service}"
fi
if [[ ! -v "_ns" ]]; then
  _ns="themartiancompany"
fi
if [[ "${_evmfs}" == "true" ]] || \
   [[ "${_git_http}" == "gitlab" ]]; then
  _archive_format="tar.gz"
elif [[ "${_git_http}" == "github" ]]; then
  _archive_format="zip"
fi
_distro=life
_component=keyring
_py="python"
_pkg="${_distro}-${_component}"
pkgbase="${_pkg}"
pkgname=(
  "${_pkg}"
)
# git rev-parse ${pkgver}
_tag="20260319"
pkgver="${_tag}"
_commit="05accdbd34af3244fd2f551cbca139a9bf6a5663"
# "$(date +%Y.%m.%d)"
pkgrel=7
_pkgdesc=(
  'Life PGP keyring.'
)
pkgdesc="${_pkgdesc[*]}"
arch=(
  'any'
)
_url="ssh://${_distro}_local_git/home/git/${_pkg}"
_http="https://${_git_service}.com"
url="${_http}/${_ns}/${_pkg}"
license=(
  'GPL3'
)
groups=(
  'base-devel'
  'hip'
)
install="${_pkg}.install"
depends=(
  'pacman'
)
makedepends=(
  "${_py}"
  'sequoia-sq'
)
if [[ "${_git}" == "true" ]]; then
  makedepends+=(
    "git"
  )
fi
checkdepends=(
  "${_py}-coverage"
  "${_py}-pytest"
)
source=()
sha256sums=()
_tag="${_commit}"
_tag_name="commit"
_url="${url}"
_tarname="${_pkg}-${_commit}"
_tarfile="${_tarname}.${_archive_format}"
_gitlab_sum="56784acce82c2d58b96f1e60aa5703f913fe3cc2bce83125373c346824af9960"
_gitlab_sig_sum="785a4cc9852a1f37ef70adf4f03b7dcc48e91791bc41bdb86a9a579b6d8c61f4"
_github_sum="2f564082843abfac42cd3f371f104715c7902325706a4ea247c83ad79ea1d169"
_github_sig_sum="9482c5b1135f6d9825a23338d9345c1da0aace3413ee47563a32a30f73aede6c"
if [[ "${_git_http}" == "github" ]]; then
  _sum="${_github_sum}"
  _sig_sum="${_github_sig_sum}"
elif [[ "${_git_http}" == "gitlab" ]]; then
  _sum="${_gitlab_sum}"
  _sig_sum="${_gitlab_sig_sum}"
fi
_evmfs_network="100"
_evmfs_address="0x69470b18f8b8b5f92b48f6199dcb147b4be96571"
# Dvorak
_evmfs_ns="0x87003Bd6C074C713783df04f36517451fF34CBEf"
_evmfs_dir="evmfs://${_evmfs_network}/${_evmfs_address}/${_evmfs_ns}"
_evmfs_uri="${_evmfs_dir}/${_sum}"
_evmfs_src="${_tarfile}::${_evmfs_uri}"
_sig_uri="${_evmfs_dir}/${_sig_sum}"
_sig_src="${_tarfile}.sig::${_sig_uri}"
if [[ "${_evmfs}" == "true" ]]; then
  if [[ "${_git}" == "false" ]]; then
  _src="${_evmfs_src}"
  source+=(
    "${_sig_src}"
  )
  sha256sums+=(
    "${_sig_sum}"
  )
  fi
elif [[ "${_evmfs}" == "false" ]]; then
  if [[ "${_git}" == "true" ]]; then
    _src="${_tarname}::git+${_url}#${_tag_name}=${_tag}?signed"
    _sum="SKIP"
  elif [[ "${_git}" == "false" ]]; then
    if [[ "${_git_http}" == "gitlab" ]]; then
      if [[ "${_tag_name}" == 'pkgver' ]]; then
        _uri="${_url}/archive/refs/tags/${_tag}.${_archive_format}"
      elif [[ "${_tag_name}" == "commit" ]]; then
        _uri="${_url}/-/archive/${_tag}/${_tag}.${_archive_format}"
      else
        _uri=""
      fi
      _src="${_tarname}.${_archive_format}::${_uri}"
    elif [[ "${_git_http}" == "github" ]]; then
      if [[ "${_tag_name}" == "commit" ]]; then
        _src="${_tarfile}::${_url}/archive/${_commit}.${_archive_format}"
      fi
    fi
  fi
fi
source=(
  "${_src}"
)
sha256sums=(
  "${_sum}"
)
validpgpkeys=(
  # Truocolo
  #   <truocolo@aol.com>
  '97E989E6CF1D2C7F7A41FF9F95684DBE23D6A3E9'
  'DD6732B02E6C88E9E27E2E0D5FC6652B9D9A6C01'
  #   <truocolo@0x6E5163fC4BFc1511Dbe06bB605cc14a3e462332b>
  'F690CBC17BD1F53557290AF51FC17D540D0ADEED'
  # Pellegrino Prevete (dvorak)
  #   <dvorak@0x87003Bd6C074C713783df04f36517451fF34CBEf>
  '12D8E3D7888F741E89F86EE0FEC8567A644F1D16'
)

build() {
  cd \
    "${_tarname}" || \
    exit
  make \
    build
}

check() {
  cd \
    "${_tarname}" || \
    exit
  make \
    check
}

package() {
  cd \
    "${_tarname}" || \
    exit
  # shellcheck disable=SC2154
  make \
    PREFIX='/usr' \
    DESTDIR="${pkgdir}" \
    install
}

# vim:set sw=2 sts=-1 et:
