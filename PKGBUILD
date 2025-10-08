# SPDX-License-Identifier: AGPL-3.0

#    ----------------------------------------------------------------------
#    Copyright © 2024, 2025  Pellegrino Prevete
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

if [[ ! -v "_offline" ]]; then
  _offline="true"
fi
if [[ ! -v "_git" ]]; then
  _git="false"
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
_tag="20251008"
pkgver="${_tag}"
_commit="8fa658cf7a39c9042d216e198a9cf0cbfc868905"
# "$(date +%Y.%m.%d)"
pkgrel=1
pkgdesc='Life PGP keyring.'
arch=(
  'any'
)
_url="ssh://${_distro}_local_git/home/git/${_pkg}"
url="https://gitlab.com/themartiancompany/${_distro}"
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
_tarname="${_pkg}-${_commit}"
if [[ "${_git}" == "true" ]]; then
  _src="${_tarname}::git+${_url}#tag=${_tag}?signed"
  _sum='SKIP'
elif [[ "${_git}" == "false" ]]; then
  _src="${_tarname}.tar.gz"
  _sum="hurr"
fi
source=(
  "${_src}"
)
sha256sums=(
  "${_sum}"
)
validpgpkeys=(
  # Pellegrino Prevete
  '3D115DD206D92A0656C827BC8B686E3C22E4C2FA'
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
