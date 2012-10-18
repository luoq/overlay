# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI=4
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils eutils flag-o-matic fortran-2 toolchain-funcs

MY_P="${PN}-${PV/_/}"
DOC_P="${PN}-0.11.0"

DESCRIPTION="Scientific algorithms library for Python"
HOMEPAGE="http://www.scipy.org/ http://pypi.python.org/pypi/scipy"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz
	doc? (
		http://docs.scipy.org/doc/${DOC_P}/${PN}-html.zip -> ${DOC_P}-html.zip
		http://docs.scipy.org/doc/${DOC_P}/${PN}-ref.pdf -> ${DOC_P}-ref.pdf
	)"

LICENSE="BSD LGPL-2"
SLOT="0"
IUSE="doc test umfpack"
KEYWORDS="~amd64 ~ppc ~ppc64 x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

CDEPEND="
	dev-python/numpy
	sci-libs/arpack
	virtual/cblas
	virtual/lapack
	umfpack? ( sci-libs/umfpack )"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	doc? ( app-arch/unzip )
	test? ( dev-python/nose )
	umfpack? ( dev-lang/swig )"
RDEPEND="${CDEPEND}
	dev-python/imaging"

S="${WORKDIR}/${MY_P}"

DOCS="THANKS.txt LATEST.txt TOCHANGE.txt"

pkg_setup() {
	fortran-2_pkg_setup
	python_pkg_setup
	# scipy automatically detects libraries by default
	export {FFTW,FFTW3,UMFPACK}=None
	use umfpack && unset UMFPACK
	# the missing symbols are in -lpythonX.Y, but since the version can
	# differ, we just introduce the same scaryness as on Linux/ELF
	[[ ${CHOST} == *-darwin* ]] \
		&& append-ldflags -bundle "-undefined dynamic_lookup" \
		|| append-ldflags -shared
	[[ -z ${FC}  ]] && export FC="$(tc-getFC)"
	# hack to force F77 to be FC until bug #278772 is fixed
	[[ -z ${F77} ]] && export F77="$(tc-getFC)"
	export F90="${FC}"
	export SCIPY_FCONFIG="config_fc --noopt --noarch"
	append-fflags -fPIC
}

src_unpack() {
	unpack ${MY_P}.tar.gz
	if use doc; then
		unzip -qo "${DISTDIR}/${DOC_P}-html.zip" -d html || die
	fi
}

pc_incdir() {
	pkg-config --cflags-only-I $@ | \
		sed -e 's/^-I//' -e 's/[ ]*-I/:/g'
}

pc_libdir() {
	pkg-config --libs-only-L $@ | \
		sed -e 's/^-L//' -e 's/[ ]*-L/:/g'
}

pc_libs() {
	pkg-config --libs-only-l $@ | \
		sed -e 's/[ ]-l*\(pthread\|m\)[ ]*//g' \
		-e 's/^-l//' -e 's/[ ]*-l/,/g'
}

src_prepare() {
	local libdir="${EPREFIX}"/usr/$(get_libdir)
	cat >> site.cfg <<-EOF
		[blas]
		include_dirs = $(pc_incdir cblas)
		library_dirs = $(pc_libdir cblas blas):${libdir}
		blas_libs = $(pc_libs cblas blas)
		[lapack]
		library_dirs = $(pc_libdir lapack):${libdir}
		lapack_libs = $(pc_libs lapack)
	EOF
}

src_compile() {
	distutils_src_compile ${SCIPY_FCONFIG}
}

src_test() {
	testing() {
		python_execute "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --home="${S}/test-${PYTHON_ABI}" --no-compile ${SCIPY_FCONFIG} || die "Installation for tests failed with $(python_get_implementation_and_version)"
		pushd "${S}/test-${PYTHON_ABI}/"lib*/python > /dev/null
		python_execute PYTHONPATH="." "$(PYTHON)" -c "import scipy; scipy.test('full')" 2>&1 | tee test.log
		grep -Eq "^(ERROR|FAIL):" test.log && return 1
		popd > /dev/null
		rm -fr test-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install ${SCIPY_FCONFIG}

	if use doc; then
		dohtml -r "${WORKDIR}/html/"*
		dodoc "${DISTDIR}/${DOC_P}-ref.pdf"
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	elog "You might want to set the variable SCIPY_PIL_IMAGE_VIEWER"
	elog "to your prefered image viewer if you don't like the default one. Ex:"
	elog "\t echo \"export SCIPY_PIL_IMAGE_VIEWER=display\" >> ~/.bashrc"
}
