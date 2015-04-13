using UnityEngine;
using System.Collections;

public class WebcamTexture : MonoBehaviour {

	WebCamTexture webcamTexture;
	public int webcamNumber;
	float cameraAspect;

	//fit camera plane to screen
	private float margin = 0f;
	public float scaleFactor = 1f;
    public bool rotatePlane = false;


	void Start ()
	{
		WebCamDevice[] devices = WebCamTexture.devices;
		int a = 0;
		foreach(WebCamDevice dev in devices){

			Debug.Log (a + ":" + dev.name);
			a = a + 1;
		}

		//webcamTexture = new WebCamTexture();
		int v = 0;
		if (webcamNumber == 0) {
			v = 1;
		} else {
			v = 4;
		}
		//v = 1;
		if(devices.Length > 0)
		{
			//webcamTexture.deviceName = devices[v].name;

			webcamTexture = new WebCamTexture (devices[v].name, 1280, 720, 30);

			Debug.Log ("tere123:4::" + v + ":" + devices[v].name);
			webcamTexture.Play();
			this.renderer.material.mainTexture = webcamTexture;
		}

        if (rotatePlane) this.transform.Rotate(Vector3.forward, 180);
		FitScreen ();
	}

	void FitScreen()
    {
		Camera cam = this.transform.parent.camera;
		
		float height = cam.orthographicSize * 1.0f;
		float width = height * Screen.width / Screen.height;
		float fix = 0;
		
		if( width > height ) fix = width + margin;
		if( width < height ) fix = height +margin;
		this.transform.localScale = new Vector3((fix/scaleFactor ) * 3/3, fix/scaleFactor, 0.1f);
	}

}
