from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
import pandas as pd
import shutil

def clean_remesas_dataset():
    input_file_path = '/usr/local/airflow/dags/datasets/inmigrantesPaisesReceptores.csv'
    output_file_path = '/usr/local/airflow/dags/datasets-cleaning/inmigrantes-cleaning.csv'

    # Cargar el archivo remesas.csv
    df = pd.read_csv(input_file_path)

    # Seleccionar solo los 10 países deseados
    paises_seleccionados = ['SWE', 'ESP', 'BEL', 'DEU', 'DNK', 'TUR', 'POL', 'SYR', 'ROU', 'MAR']
    df_cleaned = df[df['Country Code'].isin(paises_seleccionados)]

    # Guardar el archivo limpiado como remesas-cleaning.csv
    df_cleaned.to_csv(output_file_path, index=False)

    # Eliminar el archivo original
    os.remove(input_file_path)

with DAG('cleaning_inmigrantes_dag', start_date=datetime(2023, 5, 11), schedule_interval=None) as dag:
    clean_task = PythonOperator(
        task_id='clean_inmigrantes_dataset',
        python_callable=clean_remesas_dataset
    )
    
clean_task