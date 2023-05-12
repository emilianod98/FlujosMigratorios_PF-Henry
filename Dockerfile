# Archivo de Dockerfile que se utiliza para construir una imagen de Docker para Airflow.

# Define la imagen base a partir de la cual se construirá la imagen de Docker. En este caso, se utiliza la imagen "python:3.7-slim-buster", que es una imagen mínima de Python 3.7 basada en Debian.
FROM python:3.7-slim-buster
# Establece una etiqueta en la imagen Docker para indicar el autor o el responsable de mantenerla. En este caso, el valor de la etiqueta es "Puckel_".
LABEL maintainer="Puckel_"

# Establece una variable de entorno para evitar que el sistema operativo solicite interacción del usuario durante la instalación de paquetes.
ENV DEBIAN_FRONTEND noninteractive
# Establece la variable de entorno para definir el tipo de terminal como "linux".
ENV TERM linux



# AIRFLOW

# Define una variable de argumento llamada "AIRFLOW_VERSION" con un valor predeterminado de "1.10.9". Esta variable se puede reemplazar durante el proceso de compilación de Docker.
ARG AIRFLOW_VERSION=1.10.9
# Define una variable de argumento llamada "AIRFLOW_USER_HOME" con un valor predeterminado de "/usr/local/airflow". Al igual que la variable anterior, se puede reemplazar durante el proceso de compilación de Docker.
ARG AIRFLOW_USER_HOME=/usr/local/airflow
# Define una variable de argumento llamada "AIRFLOW_DEPS" sin ningún valor predeterminado. Al igual que las variables anteriores, se puede reemplazar durante el proceso de compilación de Docker.
ARG AIRFLOW_DEPS=""
# Define una variable de argumento llamada "PYTHON_DEPS" sin ningún valor predeterminado. Al igual que las variables anteriores, se puede reemplazar durante el proceso de compilación de Docker.
ARG PYTHON_DEPS=""
# Establece la variable de entorno "AIRFLOW_HOME" con el valor de la variable "AIRFLOW_USER_HOME" definida anteriormente.
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}



# Variables de entorno relacionadas con la configuración regional y el conjunto de caracteres en "en_US.UTF-8". Esto se hace para asegurarse de que Airflow funcione correctamente con caracteres especiales y configuraciones regionales específicas.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8



# Deshabilitar los mensajes de registro ruidosos de "Señal de manejo":
# ENV GUNICORN_CMD_ARGS --ADVERTENCIA de nivel de registro
# Configura el comportamiento del shell dentro del contenedor. -e significa que el shell debería salir si se encuentra un error. -x muestra los comandos que se ejecutan en el shell para propósitos de depuración
RUN set -ex \
    # Crea una variable llamada "buildDeps" y asigna una cadena de texto a ella. La cadena de texto contiene los nombres de los paquetes de dependencias que se instalarán más adelante.
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    # Actualiza la lista de paquetes disponibles dentro del sistema operativo del contenedor utilizando el comando apt-get.
    && apt-get update -yqq \
    # Realiza una actualización del sistema operativo del contenedor utilizando el comando apt-get.
    && apt-get upgrade -yqq \
    # Instala paquetes adicionales en el contenedor sin instalar recomendaciones adicionales. Los paquetes se especifican en la siguiente línea.
    && apt-get install -yqq --no-install-recommends \
        # Instala los paquetes de dependencias mencionados en la variable "buildDeps". Estos paquetes son necesarios para compilar e instalar otras bibliotecas y dependencias.
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    # Modifica el archivo /etc/locale.gen para habilitar el soporte de caracteres UTF-8 en el sistema.
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    # Genera las configuraciones regionales del sistema basadas en los cambios realizados en el paso anterior.
    && locale-gen \
    # Actualiza las variables de entorno relacionadas con la configuración regional del sistema.
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    # Crea un nuevo usuario llamado "airflow" con un shell de bash y un directorio de inicio especificado por la variable de entorno "AIRFLOW_USER_HOME".
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow \
    # Actualiza las herramientas de Python "pip", "setuptools" y "wheel" a la última versión.
    && pip install -U pip setuptools wheel \
    # Instala el paquete de Python "pytz", que proporciona funcionalidad relacionada con zonas horarias.
    && pip install pytz \
    # Instala el paquete de Python "pyOpenSSL", que proporciona una interfaz para OpenSSL.
    && pip install pyOpenSSL \
    # Instala el paquete de Python "ndg-httpsclient", que proporciona funcionalidad de cliente HTTPS.
    && pip install ndg-httpsclient \
    # Instala el paquete pyasn1 utilizando el administrador de paquetes de Python pip. El && se utiliza para ejecutar el siguiente comando solo si el comando anterior se ejecutó correctamente.
    && pip install pyasn1 \
    # Instala Apache Airflow junto con las dependencias especificadas dentro de los corchetes. También utiliza variables como AIRFLOW_DEPS y AIRFLOW_VERSION para especificar las versiones y las dependencias adicionales que se deben instalar.
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    # Este comando instala el paquete redis en la versión 3.2 utilizando pip.
    && pip install 'redis==3.2' \
    # Esta línea verifica si la variable de entorno PYTHON_DEPS tiene algún valor asignado. Si la variable tiene un valor no nulo, se ejecuta el comando pip install para instalar las dependencias de Python especificadas en esa variable.
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    # Este comando utiliza el administrador de paquetes apt-get para eliminar los paquetes que se habían instalado como dependencias de compilación. El parámetro --auto-remove indica que se deben eliminar automáticamente las dependencias que ya no son necesarias. La variable $buildDeps parece contener una lista de paquetes de compilación que se deben eliminar.
    && apt-get purge --auto-remove -yqq $buildDeps \
    # Este comando utiliza apt-get para eliminar automáticamente los paquetes que ya no son necesarios en el sistema.
    && apt-get autoremove -yqq --purge \
    # Este comando limpia la caché y los archivos temporales almacenados por apt-get.
    && apt-get clean \
    # Este comando elimina de manera recursiva y forzada los siguientes directorios y su contenido:
    && rm -rf \
        # Contiene las listas de paquetes disponibles para apt-get.
        /var/lib/apt/lists/* \
        # Directorio temporal utilizado para almacenar archivos temporales.
        /tmp/* \
        # Directorio temporal persistente utilizado para almacenar archivos temporales.
        /var/tmp/* \
        # Páginas de manual del sistema.
        /usr/share/man \
        # Documentación de paquetes instalados.
        /usr/share/doc \
        # Otra documentación relacionada con los paquetes instalados.
        /usr/share/doc-base

# Esta línea copia el archivo entrypoint.sh ubicado en la carpeta script (relativa al contexto del Dockerfile) al directorio raíz del contenedor, con el mismo nombre.
COPY script/entrypoint.sh /entrypoint.sh
# Aquí se copia el archivo airflow.cfg ubicado en la carpeta config (relativa al contexto del Dockerfile) al directorio ${AIRFLOW_USER_HOME} del contenedor, con el nombre airflow.cfg.
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

# Esta línea cambia el propietario y el grupo del directorio ${AIRFLOW_USER_HOME} y todos sus contenidos al usuario y grupo "airflow" dentro del contenedor.
RUN chown -R airflow: ${AIRFLOW_USER_HOME}

# Aquí se especifican los puertos en los que el contenedor expondrá servicios. En este caso, los puertos 8080, 5555 y 8793 están marcados como expuestos.
EXPOSE 8080 5555 8793

# Establece el usuario "airflow" como el usuario activo dentro del contenedor. A partir de este punto, los comandos que se ejecuten en el contenedor se realizarán con los permisos y privilegios asociados al usuario "airflow".
USER airflow
# Establece el directorio de trabajo (working directory) dentro del contenedor como ${AIRFLOW_USER_HOME}. Esto significa que los comandos posteriores se ejecutarán en este directorio.
WORKDIR ${AIRFLOW_USER_HOME}
# Define el punto de entrada del contenedor. Al ejecutar la imagen del contenedor, se ejecutará el script entrypoint.sh.
ENTRYPOINT ["/entrypoint.sh"]
COPY requirements.txt .
RUN pip install -r requirements.txt
# Establece el comando predeterminado a ejecutar cuando se inicie el contenedor. En este caso, el comando predeterminado es webserver, que probablemente sea el comando para iniciar el servidor web de Airflow.
CMD ["webserver"]