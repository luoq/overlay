# Copyright 2006-2011 Tiago de Paula Peixoto
# Distributed under the terms of the GNU General Public License v3

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
        EGIT_REPO_URI="git://git.skewed.de/graph-tool"
        inherit git
        SRC_URI=""
        KEYWORDS=""
else
        SRC_URI="http://downloads.skewed.de/${PN}/${P}.tar.bz2"
        KEYWORDS="~amd64 ~ppc ~x86"
fi

DESCRIPTION="An efficient python module for manipulation and statistical analysis of graphs."
HOMEPAGE="http://graph-tool.skewed.de/"
LICENSE="GPL-3"

SLOT="0"
IUSE="openmp"
KEYWORDS="~amd64 ~x86"

DEPEND=">=sys-devel/gcc-4.4
        >=dev-lang/python-2.5
	dev-libs/boost
	sci-libs/scipy
	sci-mathematics/cgal
	dev-cpp/cairomm
	dev-python/pycairo"

RDEPEND="${CDEPEND}
	media-gfx/graphviz[python]
	dev-python/matplotlib"

DOCS="README NEWS COPYING Changelog"

# most people won't have enough ram for parallel build
MAKEOPTS="-j1" 

src_compile() {

    if [[ ${PV} == "9999" ]] ; then
       ./autogen.sh
    fi
    econf $(use_enable openmp)
    emake || die "emake failed"
}
