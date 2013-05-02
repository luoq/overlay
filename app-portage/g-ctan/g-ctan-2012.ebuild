# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/g-ctan/g-ctan-2011.1.ebuild,v 1.1 2011/09/24 19:28:59 fauli Exp $

EAPI=2

DESCRIPTION="Generate and install ebuilds from the TeXLive package manager"
HOMEPAGE="http://launchpad.net/g-ctan"
SRC_URI="https://launchpad.net/g-ctan/2011/2011.1/+download/g-ctan-2011.1.tar.bz2"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~mips ~x86"

IUSE=""
DEPEND=""
RDEPEND="~app-text/texlive-2012
	app-arch/xz-utils
	>=dev-libs/libpcre-0.7.6"

src_install() {
	cd g-ctan-2011.1
	emake DESTDIR="${D}" install || die
}
