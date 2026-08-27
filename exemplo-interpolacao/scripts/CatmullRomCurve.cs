using Godot;
using System;
using System.Numerics;
using Vector3 = Godot.Vector3;
using Vector4 = System.Numerics.Vector4;
using Matrix4x4 = System.Numerics.Matrix4x4;
using System.Collections.Generic; // ← este aqui resolve o erro

public partial class CatmullRomCurve : Curve3D
{
	private static Matrix4x4 CreateCatmullRomMatrix()
	{
		return new Matrix4x4(
			-0.5f,  1.0f, -0.5f,  0.0f,   // Linha 1 = elementos das colunas 1 a 4
		 	1.5f, -2.5f,  0.0f,  1.0f,   // Linha 2
			-1.5f,  2.0f,  0.5f,  0.0f,   // Linha 3
			 0.5f, -0.5f,  0.0f,  0.0f    // Linha 4
		);
	}

	public override void GenerateCurvePoints(int curveResolution)
	{
		ClearCurvePoints();

		if (controlPoints.Count < 4)
		{
			GD.Print("Catmull-Rom requer pelo menos 4 pontos de controle.");
			return;
		}

		GD.Print("Gerando Catmull-Rom com ", controlPoints.Count, " pontos.");

		float step = 1f / curveResolution;
		
		Matrix4x4 catmullRomMatrix = CreateCatmullRomMatrix();

		// Cria uma lista estendida com cópia do primeiro e último
		List<Node3D> extendedPoints = new(controlPoints);
		extendedPoints.Insert(0, controlPoints[0]); // Primeiro duplicado no início
		extendedPoints.Add(controlPoints[controlPoints.Count - 1]);  // Último duplicado no fim

		// Agora iteramos normalmente
		for (int i = 0; i < extendedPoints.Count - 3; i++)
		{
			Vector3 p0 = extendedPoints[i].GlobalPosition;
			Vector3 p1 = extendedPoints[i + 1].GlobalPosition;
			Vector3 p2 = extendedPoints[i + 2].GlobalPosition;
			Vector3 p3 = extendedPoints[i + 3].GlobalPosition;

			Vector4 Gx = new(p0.X, p1.X, p2.X, p3.X);
			Vector4 Gy = new(p0.Y, p1.Y, p2.Y, p3.Y);
			Vector4 Gz = new(p0.Z, p1.Z, p2.Z, p3.Z);

			for (int j = 0; j < curveResolution; j++)
			{
				float t = j * step;
				Vector4 T = new(t * t * t, t * t, t, 1f);
				
				Vector4 basis = MatrixMult(catmullRomMatrix,T); // M · T

				float x = Vector4.Dot(basis, Gx);
				float y = Vector4.Dot(basis, Gy);
				float z = Vector4.Dot(basis, Gz);

				AddCurvePoint(new Vector3(x, y, z));
			}
		}

		GD.Print("Pontos da curva Catmull-Rom gerados.");
	}

	private Vector4 MatrixMult(Matrix4x4 m, Vector4 t)
	{
		return new Vector4(
			Vector4.Dot(new Vector4(m.M11, m.M12, m.M13, m.M14), t),
			Vector4.Dot(new Vector4(m.M21, m.M22, m.M23, m.M24), t),
			Vector4.Dot(new Vector4(m.M31, m.M32, m.M33, m.M34), t),
			Vector4.Dot(new Vector4(m.M41, m.M42, m.M43, m.M44), t)
		);
	}

}
