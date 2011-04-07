# Copyright 2011 Attila Oláh
# Distributed under the terms of the GNU General Public License v2

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils


DESCRIPTION="Python Image Morphology Toolbox"
HOMEPAGE="http://luispedro.org/software/pymorph http://pypi.python.org/pypi/pymorph"
SRC_URI="http://pypi.python.org/packages/source/p/${PN}/${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

DEPEND="dev-python/numpy"
RDEPEND="${DEPEND}"

python_enable_pyc
