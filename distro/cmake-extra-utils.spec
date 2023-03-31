%global upstream_name CmakeExtraUtils

Name:           cmake-extra-utils
Version:        0.0.0
Release:        %{autorelease}
Summary:        Helpful cmake scripts

License:        GPL-3.0-or-later
URL:            https://github.com/LecrisUT/%{upstream_name}
Source0:        https://github.com/LecrisUT/%{upstream_name}/archive/refs/tags/v%{version}.tar.gz
Source1:        %{name}.rpmlintrc

BuildArch:      noarch
BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
Requires:       cmake

%description
A collection of helpful cmake scripts

%prep
%autosetup -n %{upstream_name}-%{version}

%build
%cmake
%cmake_build

%install
%cmake_install

%check
%ctest

%files
%license LICENSE
%doc README.md
%{_datadir}/cmake/CMakeExtraUtils

%changelog
%autochangelog
