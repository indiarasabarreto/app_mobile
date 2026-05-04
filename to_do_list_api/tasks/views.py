from rest_framework import viewsets
from .models import Task
from .serializers import TaskSerializer
from datetime import date

class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    

def get_queryset(self):
    today = date.today()
    tasks = Task.objects.filter(data=today)