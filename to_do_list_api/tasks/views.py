from rest_framework import viewsets, permissions
from .models import Task
from .serializers import TaskSerializer

class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    
    # Now Django knows what 'permissions' is and will allow open access
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        # Returns all tasks ordered by section
        return Task.objects.all().order_by('section', 'title')