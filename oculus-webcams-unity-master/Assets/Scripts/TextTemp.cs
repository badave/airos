using UnityEngine;
using System.Collections;
using System.IO.Ports;

public class TextTemp : MonoBehaviour
{
	
	public GameObject flame;
	private TextMesh bubbleText;
	private bool bubbleStatus = false;
	public string sensorName;
	public int clipIndex = 0; //First Temperature Reading

	int updint = 30;
	int updc = 0;
	
	SerialPort stream = new SerialPort("COM5", 9600); //Set the port (com4) and the baud rate (9600, is standard on most devices)
	
	
	// Use this for initialization
	void Start ()
	{
		//bubbleText = textObject.GetComponentInChildren<TextMesh> ();
		bubbleText = gameObject.GetComponent<TextMesh>(); 
		stream.Open(); //Open the Serial Stream.
	}
	
	// Update is called once per frame
	void Update ()
	{
		updateSensorText();
		//For testing only"
	}
	
	public float textSizeStart = 125f;
	public float textSizeModifier = 5f;
	
	void updateSensorText ()
	{
		updc ++;
		if (updc > updint) {
			updc = 0;
			string value = stream.ReadLine (); //Read the information
			string temp = value.Split(';')[0];
			string flameval = value.Split(';')[1];
			bool flameb = flameval == "1";
			flame.renderer.enabled = flameb;
			Debug.Log (value);
			Debug.Log (flameval + ";" + flameb);
			Debug.Log ("whaat");
			bubbleText.text = temp + "°C";
			stream.BaseStream.Flush (); //Clear the serial information so we assure we get new information.
		}
	}

	
}