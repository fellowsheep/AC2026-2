using Godot;
using System;

public partial class LinearCurve : Curve3D
{

	public override void _Ready()
	{
		base._Ready();
	}

	public override void GenerateCurvePoints(int curveRes)
	{
		ClearCurvePoints();

		if (controlPoints.Count < 2)
		{
			GD.Print("É necessário pelo menos 2 pontos de controle para interpolação linear.");
			return;
		}

		GD.Print("Gerando os pontos da curva...");
		for (int i = 0; i < controlPoints.Count - 1; i++)
		{
			Vector3 p0 = controlPoints[i].GlobalPosition;
			Vector3 p1 = controlPoints[i + 1].GlobalPosition;

			for (int j = 0; j <= curveRes; j++)
			{
				float t = (float)j / curveRes;
				Vector3 point = p0.Lerp(p1, t);
				AddCurvePoint(point);
			}
		}
		GD.Print("Pontos da curva gerados...");
	}
}
