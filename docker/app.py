COPY app.py /opt/tg-signer/
WORKDIR /opt/tg-signer
EXPOSE 8080
CMD ["python", "app.py"]
