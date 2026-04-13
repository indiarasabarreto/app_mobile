from django.db import models

class Task(models.Model):
    # O que precisa ser feito:
    title = models.CharField(max_length=200)

    # Onde será feito:
    section = models.CharField(max_length=100, default="Geral")

    # Quem ficará responsável:
    responsible = models.CharField(max_length=100, blank=True)
    completed = models.BooleanField(default=False)


    def __str__(self):
        return f"{self.title} - {self.section}"
