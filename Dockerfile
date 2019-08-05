FROM alpine:3.10

ENV REFRESHED_AT 20190726

ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa

RUN apk add --no-cache alpine-sdk xz libxml2-dev pango-dev m4 libtool perl autoconf automake coreutils python-dev zlib-dev freetype-dev glib-dev cmake tiff-dev readline-dev jpeg-dev giflib-dev flex bison gettext gettext-dev cairo cairo-dev libpng python freetype glib libintl libxml2 libltdl pango openjpeg-dev openjpeg openjpeg-tools

# Install libspiro
RUN cd / && \
    wget https://github.com/fontforge/libspiro/archive/0.5.20150702.tar.gz && \
    tar -xf 0.5.20150702.tar.gz && \
    cd libspiro-0.5.20150702 && \
    autoreconf -i && \
    automake --foreign -Wall && \
    ./configure && \
    make && make install

# Install libiconv
RUN cd / && \
    wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz && \
    tar -xf libiconv-1.16.tar.gz && \
    cd libiconv-1.16/ && \
    ./configure --prefix=/usr/local && \
    make && make install

# Install fontforge
RUN cd / && \
    wget https://github.com/fontforge/fontforge/archive/20170730.tar.gz && \
    tar -xf 20170730.tar.gz && \
    cd fontforge-20170730 && \
    ./bootstrap --force && \
    ./configure --without-x --without-iconv && \
    make && make install


RUN ln -s /usr/include/openjpeg-2.3/*  /usr/include/
# Install poppler
RUN cd / && \
    wget http://poppler.freedesktop.org/poppler-0.62.0.tar.xz && \
    tar -xf poppler-0.62.0.tar.xz && \
    cd poppler-0.62.0 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DTESTDATADIR=$PWD/testfiles -DENABLE_XPDF_HEADERS=ON  .. && \
    make && make install && install -v -m755 -d /usr/share/doc/poppler-0.62.0 && cp -vr ../glib/reference/html /usr/share/doc/poppler-0.62.0

# Install poppler-data
RUN cd / && \
    wget http://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz && \
    tar -xf poppler-data-0.4.9.tar.gz && \
    cd poppler-data-0.4.9 && \
    make prefix=/usr/local install

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib64
ENV PKG_CONFIG_PATH $PKG_CONFIG_PATH:/usr/lib64/pkgconfig

# Install ttfautohint
RUN cd / && \
    wget http://download.savannah.gnu.org/releases/freetype/ttfautohint-0.97.tar.gz && \
    tar -xf ttfautohint-0.97.tar.gz && \
    cd ttfautohint-0.97 && \
    ./configure --without-qt && \
    make && make install

# Install pdf2htmlEX
RUN cd / && \
    git clone https://github.com/iapain/pdf2htmlEX.git && \
    cd pdf2htmlEX && git checkout qapint-hard-work
    #cmake . && make && sudo make install

#RUN rm -rf /root/.ssh && \
#    rm -rf /fontforge* /libspiro* /poppler* /pdf2htmlEX /libiconv* /ttfautohint*

VOLUME /pdf
WORKDIR /pdf

CMD ["/usr/local/bin/pdf2htmlEX"]

