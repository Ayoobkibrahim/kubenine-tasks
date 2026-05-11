FROM python:3.10-slim AS builder

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY app.py /app/

FROM python:3.10-slim

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app/app.py /app/

EXPOSE 5000

CMD ["python", "app.py"]