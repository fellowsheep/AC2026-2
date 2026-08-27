using Godot;
using System;
using Godot.Collections;

public partial class Curve3D : Node3D
{
	[Export] public PackedScene ControlPointScene;
	[Export] public PackedScene CurvePointScene;
	[Export] public Material CurvePointMaterial;
	
	[Export] public int curveResolution = 10;

	protected Array<Node3D> controlPoints = new();
	protected Array<Node3D> curvePoints = new();
	

	public override void _Ready()
	{
		GD.Print("Iniciou!");
		// Aguarda a cena estar totalmente carregada antes de acessar os filhos
		CallDeferred(nameof(CollectControlPoints));
	}

	public void CollectControlPoints()
	{
		GD.Print("Coletando Control Points!");
		var container = GetNodeOrNull<Node3D>("../ControlPoints");

		if (container != null)
		{
			foreach (Node child in container.GetChildren())
			{
				if (child is Node3D point)
				{
					controlPoints.Add(point);
				}
			}

			GD.Print("ControlPoints carregados: ", controlPoints.Count);
		}
		else
		{
			GD.Print("Nó 'ControlPoints' não encontrado no node " + Name);
		}
		
		// Só gera curva se houver pelo menos 2 pontos
		if (controlPoints.Count >= 2)
		{
			GenerateCurvePoints(curveResolution);
		}
	}

	protected void AddCurvePoint(Vector3 position)
	{
		if (CurvePointScene == null)
		{
			GD.Print("CurvePointScene não atribuída.");
			return;
		}

		var instance = CurvePointScene.Instantiate<Node3D>();
		instance.Position = position;

		if (CurvePointMaterial != null && instance is MeshInstance3D meshInstance)
		{
			meshInstance.MaterialOverride = CurvePointMaterial;
		}

		AddChild(instance);
		curvePoints.Add(instance);
	}

	protected void ClearCurvePoints()
	{
		foreach (var point in curvePoints)
		{
			point.QueueFree();
		}

		curvePoints.Clear();
	}

	public virtual void GenerateCurvePoints(int curveRes)
	{
		//GD.Print("Método GenerateCurvePoints não implementado.");
	}
}
