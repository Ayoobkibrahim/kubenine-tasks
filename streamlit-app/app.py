import streamlit as st
import os
import boto3

st.set_page_config(page_title="Task 3.47 Streamlit App", layout="centered")
st.title("Task 3.47 - ECS Fargate Streamlit App")

st.write("App is running on ECS Fargate behind ALB.")

bucket_name = os.getenv("APP_S3_BUCKET", "not-set")
st.write(f"S3 bucket from env: {bucket_name}")

if bucket_name != "not-set":
    try:
        s3 = boto3.client("s3")
        objs = s3.list_objects_v2(Bucket=bucket_name, MaxKeys=5)
        keys = [x["Key"] for x in objs.get("Contents", [])]
        st.write("Sample keys from bucket:", keys if keys else "No objects found")
    except Exception as e:
        st.error(f"S3 access failed: {e}")