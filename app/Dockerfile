FROM python:2.7
LABEL maintainer="Mohamed Radwan"

# Place app in container.
COPY . /opt/www
WORKDIR /opt/www

# Install dependencies.
RUN pip install -r requirements.txt

EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["runserver.py"]
