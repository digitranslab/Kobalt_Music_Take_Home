from fastapi import FastAPI, HTTPException
import boto3
import os

app = FastAPI()

emr_client = boto3.client('emr', region_name=os.environ.get('REGION'))

@app.get("/api/clusters")
def list_clusters():
    try:
        clusters = emr_client.list_clusters(ClusterStates=['RUNNING', 'WAITING'])
        cluster_info = [
            {
                "id": cluster['Id'],
                "name": cluster['Name'],
                "runningHours": (cluster['Status']['Timeline']['ReadyDateTime'] - cluster['Status']['Timeline']['CreationDateTime']).total_seconds() / 3600
            }
            for cluster in clusters['Clusters']
        ]
        return cluster_info
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/clusters/{cluster_id}/terminate")
def terminate_cluster(cluster_id: str):
    try:
        emr_client.terminate_job_flows(JobFlowIds=[cluster_id])
        return {"message": "Cluster terminated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 