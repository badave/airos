using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TextBattery : MonoBehaviour {
	
	TextMesh txt;
	private double currentscore=100;
	
	// Use this for initialization
	void Start () {
		txt = gameObject.GetComponent<TextMesh>(); 
		Debug.Log ("Text:" + txt + ";" + txt.text);
	}
	
	// Update is called once per frame
	void Update () {
		currentscore -= 0.001;
		txt.text=currentscore.ToString("F2") + "%";  
		//currentscore = PlayerPrefs.GetInt("TOTALSCORE"); 
		//PlayerPrefs.SetInt("SHOWSTARTSCORE",currentscore); 
	}
}
