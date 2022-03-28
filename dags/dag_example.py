from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.bash import BashOperator
from datetime import datetime
import pendulum
import os

home_path = os.path.expanduser("~")
local_tz = pendulum.timezone("Asia/Seoul")

with DAG(
    dag_id="dag-example",
    description="DAG 테스트",
    default_args={
        "owner": "magae",
        "depends_on_past": False,
        "start_date": datetime(2022,3,27, tzinfo=local_tz)
    },
    schedule_interval="0 3 * * *",
    catchup=False,
    tags=["DAG", "Test"]
) as dag:

    start_operator = DummyOperator(task_id="start_dag")
    end_operator = DummyOperator(task_id="end_dag")

    test_operator = BashOperator(
        task_id="test",
        bash_command="echo test"
    )

    start_operator >> test_operator >> end_operator
