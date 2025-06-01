FROM python:3.12-slim AS builder

RUN echo "Types: deb\n\
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian\n\
Suites: bookworm bookworm-updates bookworm-backports\n\
Components: main contrib non-free non-free-firmware\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg\n\n\
Types: deb\n\
URIs: https://security.debian.org/debian-security\n\
Suites: bookworm-security\n\
Components: main contrib non-free non-free-firmware\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" \
> /etc/apt/sources.list.d/debian.sources

RUN apt-get update && apt-get install -y gcc && \
    pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && \
    mkdir -p build && \
    pip wheel -w build tgcrypto

FROM python:3.12-slim
COPY --from=builder /build/*.whl /tmp/
COPY --from=builder /etc/apt/sources.list.d/debian.sources/* /etc/apt/sources.list.d/debian.sources/

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y tzdata && \
    pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && \
    pip install /tmp/*.whl && \
    pip install -U "tg-signer[tgcrypto]"
RUN pip install flask

WORKDIR /opt/tg-signer
COPY app.py /opt/tg-signer/
WORKDIR /opt/tg-signer
EXPOSE 8080
CMD ["python", "app.py"]
