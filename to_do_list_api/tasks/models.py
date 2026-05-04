from django.db import models

class Task(models.Model):
    # O que precisa ser feito:
    title = models.CharField(max_length=255)

    # Onde será feito:
    section = models.CharField(max_length=100)

    # Quem ficará responsável:
    responsible = models.CharField(max_length=100)
    completed = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    made_by = models.CharField(max_length=100, blank=True, null=True)






      