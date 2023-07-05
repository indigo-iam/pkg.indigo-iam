%define name            iam-login-service
%define base_version    1.8.1p1
%define base_release    1

%define user            iam

%define jdk_version     17
%define mvn_version     3.3.0

%if %{?build_number:1}%{!?build_number:0}
%define release_version 0.build.%{build_number}
%else
%define release_version %{base_release}
%endif

Name:		%{name}
Version:	%{base_version}
Release:	%{release_version}%{?dist}
Summary:	INDIGO Identity and Access Management Service.

Group:		Applications/Web
License:	apache2
URL:		https://github.com/indigo-iam/iam

BuildArch: noarch
BuildRequires: java-%{jdk_version}-openjdk-devel
BuildRequires: maven >= %{mvn_version}

Requires:	java-%{jdk_version}-openjdk

%description
The INDIGO IAM (Identity and Access Management service) provides 
user identity and policy information to services so that consistent 
authorization decisions can be enforced across distributed services.

%prep

%build
cd $HOME/sources/%{name}
mvn -U -B -DskipTests clean package

%install
cd ${RPM_BUILD_ROOT}
mkdir -p var/lib/indigo/%{name}
mkdir -p usr/lib/systemd/system
mkdir -p etc/sysconfig
mkdir -p etc/%{name}/config
cp $HOME/sources/%{name}/%{name}/target/%{name}.war var/lib/indigo/%{name}
cp $HOME/sources/%{name}/rpm/SOURCES/%{name}.service usr/lib/systemd/system
cp $HOME/sources/%{name}/rpm/SOURCES/%{name} etc/sysconfig

%clean

%pre

%post
/usr/bin/id -u %{user} > /dev/null 2>&1
if [ $? -eq 1 ]; then
  useradd --comment "INDIGO IAM" --system --user-group --home-dir /var/lib/indigo/%{name} --no-create-home --shell /sbin/nologin %{user}
fi
chown -R %{user}:%{user} /var/lib/indigo/%{name}
systemctl daemon-reload

%preun
systemctl stop %{name}

%postun
systemctl daemon-reload

%files
%config(noreplace) /etc/sysconfig/iam-login-service
%dir /etc/%{name}
%dir /etc/%{name}/config
%dir /var/lib/indigo
%dir /var/lib/indigo/%{name}
/var/lib/indigo/%{name}/%{name}.war
/usr/lib/systemd/system/%{name}.service

%changelog
* Tue Jul 04 2023 Enrico Vianello <enrico.vianello@cnaf.infn.it> 1.8.2p1
- Release 1.8.2p1

* Tue Jul 04 2023 Enrico Vianello <enrico.vianello@cnaf.infn.it> 1.8.1p1
- Release 1.8.1p1

* Wed Dec 07 2022 Enrico Vianello <enrico.vianello@cnaf.infn.it> 1.8.0
- Release 1.8.0

* Thu Jul 28 2022 Enrico Vianello <enrico.vianello@cnaf.infn.it> 1.8.0
- WIP Release 1.8.0

* Fri Dec 03 2021 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.7.2
- Release 1.7.2

* Sat Sep 11 2021 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.7.1
- Release 1.7.1

* Tue Aug 31 2021 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.7.0
- Release 1.7.0

* Fri Dec 13 2019 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.6.0
- Release 1.6.0

* Thu Oct 31 2019 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.5.0
- Release 1.5.0

* Thu May 17 2018 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.4.0
- Release 1.4.0

* Thu Jan 25 2018 Marco Caberletti <marco.caberletti@cnaf.infn.it> 1.2.0
- Release 1.2.0

* Fri Sep 29 2017 Andrea Ceccanti <andrea.ceccanti@cnaf.infn.it> 1.1.0
- Release 1.1.0.

* Tue Aug 8 2017 Marco Caberletti <marco.caberletti@cnaf.infn.it> 1.0.0
- Release 1.0.0.

* Thu Apr 27 2017 Marco Caberletti <marco.caberletti@cnaf.infn.it> 0.6.0
- Initial IAM Login Service for Indigo 2.
