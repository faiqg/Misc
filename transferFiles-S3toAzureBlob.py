# to run 
# `pip install requests azure-storage-blob` 
# `python transferFiles-S3toAzure.py`

#this code parses this XML format
#<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> 
#<Name>mydataset</Name> 
#<Prefix/> <Marker/> <MaxKeys>1000</MaxKeys> <IsTruncated>true</IsTruncated> 
#<Contents> <Key>folderName/</Key> <LastModified>2025-01-13T22:55:50.000Z</LastModified> 
#<ETag>"939393939"</ETag> <Size>0</Size> <StorageClass>STANDARD</StorageClass> 
#</Contents> 
#</ListBucketResult>

from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
import xml.etree.ElementTree as ET
import requests
import os

#target 
AZURE_CONNECTION_STRING = "DefaultEndpointsProtocol=https;AccountName=<accountname>;AccountKey=<accountkey>;EndpointSuffix=core.windows.net"
CONTAINER_NAME = "containername"
#source
BUCKET_URL = "https://bucketurl.s3.ap-southeast-2.amazonaws.com/"

#uncomment if you want to download the files locally too
#DOWNLOAD_DIR = "/Users/localpath/"
#os.makedirs(DOWNLOAD_DIR, exist_ok=True)

def get_file_list(marker=None):
    url = f"{BUCKET_URL}?marker={marker}" if marker else BUCKET_URL
    response = requests.get(url)
    root = ET.fromstring(response.content)

    ns = {"s3": "http://s3.amazonaws.com/doc/2006-03-01/"}
    keys = [elem.text for elem in root.findall(".//s3:Key", ns)]
    
    is_truncated = root.find(".//s3:IsTruncated", ns).text.lower() == "true"
    last_key = keys[-1] if keys else None

    return keys, is_truncated, last_key

# uncomment if you want to download the files locally too
# def download_files(files):
#     for key in files:
#         file_url = f"{BUCKET_URL}{key}"
#         file_path = os.path.join(DOWNLOAD_DIR, os.path.basename(key))
        
#         # response = requests.get(file_url, stream=True)
#         # with open(file_path, "wb") as f:
#         #     for chunk in response.iter_content(chunk_size=8192):
#         #         f.write(chunk)
#         # print(f"Downloaded: {file_path}")
#         if key.endswith('/'):
#             os.makedirs(file_path, exist_ok=True)
#             print(f"Created directory: {file_path}")
#         else:
#             os.makedirs(os.path.dirname(file_path), exist_ok=True)
#             response = requests.get(file_url, stream=True)
#             with open(file_path, "wb") as f:
#                 for chunk in response.iter_content(chunk_size=8192):
#                     f.write(chunk)
#             print(f"Downloaded: {file_path}")

def upload_file_to_azure(blob_service_client, file_url, blob_name):
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    response = requests.get(file_url, stream=True)
    blob_client.upload_blob(response.raw, overwrite=True)
    print(f"Uploaded: {file_url} to {blob_name}")

def process_files(files, blob_service_client):
    for key in files:
        file_url = f"{BUCKET_URL}{key}"
        if key.endswith('/'):
            print(f"Skipping directory: {key}")
        else:
            upload_file_to_azure(blob_service_client, file_url, key)

# Initialize BlobServiceClient
blob_service_client = BlobServiceClient.from_connection_string(AZURE_CONNECTION_STRING)

# Fetch and process all files
marker = None
while True:
    files, is_truncated, marker = get_file_list(marker)
    # uncomment if you want to download the files locally too
    # download_files(files)
    process_files(files, blob_service_client)
    if not is_truncated:
        break
