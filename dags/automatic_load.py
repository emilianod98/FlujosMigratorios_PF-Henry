from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
import pandas as pd
import csv
from airflow.operators.dummy_operator import DummyOperator


def load_csv(file_path):
    data = []
    with open(file_path, 'r') as file:
        csv_reader = csv.reader(file)
        header = next(csv_reader)
        for row in csv_reader:
            data.append(row)
    return data

def save_csv(file_path, data, header=None):
    with open(file_path, 'w', newline='') as file:
        csv_writer = csv.writer(file)
        if header:
            csv_writer.writerow(header)
        csv_writer.writerows(data)

def incremental_load(old_file, new_file, output_file):
    old_data = load_csv(old_file)
    new_data = load_csv(new_file)

    existing_data = {(row[2], row[0]): row for row in old_data}
    new_rows = [row for row in new_data if (row[2], row[0]) not in existing_data]

    merged_data = old_data + new_rows
    save_csv(output_file, merged_data, header=new_data[0])

def sort_data(input_file, output_file):
    data = pd.read_csv(input_file)
    data['Year'] = pd.to_numeric(data['Year'])
    data.sort_values(by=['Country Name', 'Year'], inplace=True)
    data.to_csv(output_file, index=False)

# Especifica los nombres de los archivos de entrada y salida
old_csv_file = '/usr/local/airflow/dags/datasets/incremental_load/homicides100k_1990-2018.csv'
new_csv_file = '/usr/local/airflow/dags/datasets/incremental_load/homicides100k_2019.csv'
output_csv_file = '/usr/local/airflow/dags/datasets/homicides100k.csv'
sorted_csv_file = '/usr/local/airflow/dags/datasets/homicides100k_sorted.csv'

# Definir los argumentos del DAG
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 5, 15),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

# Crear el objeto DAG
dag = DAG(
    'incremental_load_dag',
    default_args=default_args,
    description='Carga incremental de datos',
    schedule_interval=None,
)

# Definir las tareas del DAG
load_task = PythonOperator(
    task_id='load_data',
    python_callable=incremental_load,
    op_kwargs={'old_file': old_csv_file, 'new_file': new_csv_file, 'output_file': output_csv_file},
    dag=dag
)

sort_task = PythonOperator(
    task_id='sort_data',
    python_callable=sort_data,
    op_kwargs={'input_file': output_csv_file, 'output_file': sorted_csv_file},
    dag=dag
)

# Nuevo operador para guardar el archivo CSV ordenado
save_sorted_csv_task = BashOperator(
    task_id='save_sorted_csv',
    bash_command=f"cp {sorted_csv_file} {output_csv_file}",
    dag=dag
)

# Definir una tarea final para marcar la finalización del DAG
end_task = DummyOperator(
    task_id='end_task',
    dag=dag
)

# Definir las dependencias del DAG
sort_task.set_upstream(load_task)
sort_task >> save_sorted_csv_task
end_task.set_upstream(save_sorted_csv_task)