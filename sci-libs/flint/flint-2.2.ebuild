# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Fast Library for Number Theory"
HOMEPAGE="http://www.flintlib.org/"
SRC_URI="http://www.flintlib.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc examples"

DEPEND="dev-libs/mpfr
	sci-libs/mpir
	dev-libs/gmp
	doc? ( virtual/latex-base )"
RDEPEND="${DEPEND}"

src_configure() {
	./configure --prefix=${ED}usr/
}
src_compile() {
	emake
	if use doc ; then
		cd doc/latex
		emake
	fi
}
src_install() {
	einstall
	dodoc README NEWS AUTHORS code_conventions.txt doc/*.txt
	if use doc ;then
		dodoc doc/latex/flint-manual.pdf
	fi
	if use examples ; then
		insinto /usr/share/doc/${PF}/
		doins -r examples
	fi
}
