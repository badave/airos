using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TextO2 : MonoBehaviour {

	TextMesh txt;
	private double currentscore=100;
	
	// Use this for initialization
	void Start () {
		txt = gameObject.GetComponent<TextMesh>(); 
		txt.text="" + currentscore;
		Debug.Log ("Text:" + txt + ";" + txt.text);
	}
	
	// Update is called once per frame
	void Update () {
		currentscore -= 0.0001;
		txt.text="" + currentscore.ToString("F2") + "%";  
		//currentscore = PlayerPrefs.GetInt("TOTALSCORE"); 
		//PlayerPrefs.SetInt("SHOWSTARTSCORE",currentscore); 
	}
}
