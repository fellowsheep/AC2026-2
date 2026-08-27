using Godot;
using System;
using System.Collections.Generic;

public partial class Rato : Node3D
{
	[Export] public NodePath CurveNodePath;
	[Export] public float Speed = 5f;

	private List<Node3D> curvePoints = new();
	private int currentIndex = 0;

	public override void _Ready()
	{
		GD.Print("Rato acordou e está pronto para caçar queijo!");
		
		 CallDeferred(nameof(SetupPath));

	}

	private void SetupPath()
	{
		var curveNode = GetNodeOrNull<Node3D>(CurveNodePath);
		if (curveNode == null)
		{
			GD.Print("Nó da curva não encontrado!");
			return;
		}

		foreach (Node child in curveNode.GetChildren())
		{
			if (child is Node3D point)
			{
				curvePoints.Add(point);
				//GD.Print($"Ponto adicionado: {point.Name}");
			}
		}

		GD.Print($"Total de pontos na curva: {curvePoints.Count}");

		if (curvePoints.Count > 0)
			GlobalTransform = GlobalTransform with { Origin = curvePoints[0].GlobalPosition };
	}



	public override void _Process(double delta)
	{
		
		
		if (curvePoints.Count < 2 || currentIndex >= curvePoints.Count - 1)
		{
			//GD.Print($"Nro de pontos da curva: {curvePoints.Count}");
			return;
		}
			
		//GD.Print($"Rato em {GlobalPosition}, indo para {curvePoints[currentIndex + 1].GlobalPosition}");

		var from = GlobalPosition;
		var to = curvePoints[currentIndex + 1].GlobalPosition;

		// Calcular vetor de direção e distância até o próximo ponto
		var toVector = to - from;
		var distanceToNext = toVector.Length();

		if (distanceToNext < 0.01f)
		{
			currentIndex++;
			return;
		}

		var direction = toVector.Normalized();
		var step = Speed * (float)delta;

		// Se o passo for maior que a distância até o ponto, pula direto pro ponto
		if (step >= distanceToNext)
		{
			GlobalPosition = to;
			currentIndex++;
		}
		else
		{
			GlobalPosition += direction * step;
			LookAt(to, Vector3.Up);
		}
	}

	
}
