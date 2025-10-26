FROM debian:12

ENV PATH /usr/local/bin:$PATH

ENV GPG_KEY 7169605F62C751356D054A26A821E680E5FA6305
ENV PYTHON_VERSION 3.13.7
ENV PYTHON_SHA256 5462f9099dfd30e238def83c71d91897d8caa5ff6ebc7a50f14d4802cdaaa79a

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	  ca-certificates \
		netbase \
		tzdata \
		dpkg-dev \
		gcc \
		gnupg \
		libbluetooth-dev \
		libbz2-dev \
		libc6-dev \
		libdb-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		make \
		tk-dev \
		uuid-dev \
		wget \
		xz-utils \
		zlib1g-dev \
		bash \
		busybox \
		traceroute \
	; \
	\
	wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
	echo "$PYTHON_SHA256 *python.tar.xz" | sha256sum -c -; \
	wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; \
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY"; \
	gpg --batch --verify python.tar.xz.asc python.tar.xz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" python.tar.xz.asc; \
	mkdir -p /usr/src/python; \
	tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; \
	rm python.tar.xz; \
	\
	cd /usr/src/python; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		$(test "${gnuArch%%-*}" != 'riscv64' && echo '--with-lto') \
		--with-ensurepip \
	; \
	nproc="$(nproc)"; \
	EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
	LDFLAGS="${LDFLAGS:--Wl},--strip-all"; \
		arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
		case "$arch" in \
			amd64|arm64) \
				EXTRA_CFLAGS="${EXTRA_CFLAGS:-} -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer"; \
				;; \
			i386) \
				# don't enable frame-pointers on 32bit x86 due to performance drop.
				;; \
			*) \
				# other arches don't support "-mno-omit-leaf"
				EXTRA_CFLAGS="${EXTRA_CFLAGS:-} -fno-omit-frame-pointer"; \
				;; \
		esac; \
	make -j "$nproc" \
		"EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
		"LDFLAGS=${LDFLAGS:-}" \
	; \
	rm python; \
	make -j "$nproc" \
		"EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
		"LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
		python \
	; \
	make install; \
	\
	cd /; \
	rm -rf /usr/src/python; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
		\) -exec rm -rf '{}' + \
	; \
	\
	ldconfig;
RUN apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -rt dpkg-query --search \
# https://manpages.debian.org/bookworm/dpkg/dpkg-query.1.en.html#S (we ignore diversions and it'll be really unusual for more than one package to provide any given .so file)
		| awk 'sub(":$", "", $1) { print $1 }' \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	# apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	# rm -rf /var/lib/apt/lists/*; \
	\
	export PYTHONDONTWRITEBYTECODE=1; \
	python3 --version; \
	pip3 --version

# make some useful symlinks that are expected to exist ("/usr/local/bin/python" and friends)
RUN set -eux; \
	for src in idle3 pip3 pydoc3 python3 python3-config; do \
		dst="$(echo "$src" | tr -d 3)"; \
		[ -s "/usr/local/bin/$src" ]; \
		[ ! -e "/usr/local/bin/$dst" ]; \
		ln -svT "$src" "/usr/local/bin/$dst"; \
	done


ENV LANG='en_US.UTF-8' \
  LANGUAGE='en_US:en' \
  LC_ALL='en_US.UTF-8' \
  JAVA_VERSION=jdk-24.0.2+12 \
  ALLURE_VERSION=2.35.1 \
  JAVA_HOME=/opt/java/openjdk \
  UID=1010 \
  USER=appuser

# Set PATH after JAVA_HOME and ALLURE_HOME are defined
ENV ALLURE_HOME=/opt/allure/allure-$ALLURE_VERSION 
ENV PATH="$JAVA_HOME/bin:$ALLURE_HOME/bin:$PATH"

RUN set -eux; \
      apt-get install -y --no-install-recommends \
      curl \
      wget \
      gnupg \
      unzip \
      fontconfig \
      ca-certificates p11-kit \
      binutils \
      tzdata \
      locales \
      fonts-dejavu-core \
      openssl \
      bash \
      net-tools \
      dnsutils \
  ; \
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
  locale-gen en_US.UTF-8


RUN set -eux; \
  ARCH="$(dpkg --print-architecture)"; \
  case "${ARCH}" in \
     amd64) \
       ESUM='bee902852ae8b6698e04eb1599dc94af844ae45b72b3b8ec854350b9aba41335'; \
       BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_x64_linux_hotspot_24.0.2_12.tar.gz'; \
       ;; \
     arm64) \
       ESUM='6b06ed1d91930ef86afc7d2159948aa9b3054b154cd8afda35d1fddd158fc11d'; \
       BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_aarch64_linux_hotspot_24.0.2_12.tar.gz'; \
       ;; \
     ppc64el) \
       ESUM='de9ec7034fb369ec9b5d12bba9d51984d14d859006e89ef2b86bbae9bc4c7ae4'; \
       BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_ppc64le_linux_hotspot_24.0.2_12.tar.gz'; \
       ;; \
     riscv64) \
       ESUM='4a1177077bc5937ec93cfaaff60fd212a8591af241827869c73f87949a1268e9'; \
       BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_riscv64_linux_hotspot_24.0.2_12.tar.gz'; \
       ;; \
     s390x) \
       ESUM='b25ab757f131f965195fd2cb63853299ed6bef268c845283a5a9fff562840fe2'; \
       BINARY_URL='https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.2%2B12/OpenJDK24U-jre_s390x_linux_hotspot_24.0.2_12.tar.gz'; \
       ;; \
     *) \
       echo "Unsupported arch: ${ARCH}"; \
       exit 1; \
       ;; \
  esac; \
  wget --progress=dot:giga -O /tmp/openjdk.tar.gz ${BINARY_URL}; \
  wget --progress=dot:giga -O /tmp/openjdk.tar.gz.sig ${BINARY_URL}.sig; \
  export GNUPGHOME="$(mktemp -d)"; \
  # gpg: key 843C48A565F8F04B: "Adoptium GPG Key (DEB/RPM Signing Key) <temurin-dev@eclipse.org>" imported
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 3B04D753C9050D9A5D343F39843C48A565F8F04B; \
  gpg --batch --verify /tmp/openjdk.tar.gz.sig /tmp/openjdk.tar.gz; \
  rm -rf "${GNUPGHOME}" /tmp/openjdk.tar.gz.sig; \
  echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
  mkdir -p "$JAVA_HOME"; \
  tar --extract \
      --file /tmp/openjdk.tar.gz \
      --directory "$JAVA_HOME" \
      --strip-components 1 \
      --no-same-owner \
  ; \
  rm -f /tmp/openjdk.tar.gz; \
  # https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
  find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
  ldconfig; \
  java -Xshare:dump;

RUN set -eux; \
  echo "Verifying install ..."; \
  echo "java --version"; java --version; \
  echo "Complete."
COPY --chmod=755 entrypoint.sh /cacert_entrypoint.sh

#############
RUN set -eux; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3 python3-pip
RUN curl -o allure-commandline.zip https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.zip \
  && unzip allure-commandline.zip -d /opt/allure \
  && rm -rf allure-commandline.zip

RUN adduser \
  --disabled-password \
  --gecos "" \
# --no-create-home \
  --uid "$UID" \
  --shell "/bin/bash" \
  $USER && \
chmod 755 /cacert_entrypoint.sh;

RUN apt-get remove wget unzip -y \
&& rm -rf /var/cache/apt/archives /var/lib/apt/lists
ENTRYPOINT ["/cacert_entrypoint.sh"]
USER $USER


CMD ["python3"]