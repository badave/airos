using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TextBPM : MonoBehaviour {
	
	TextMesh txt;
	private float currentscore=100;
	int updint = 30;
	int updc = 0;
	
	// Use this for initialization
	void Start () {
		txt = gameObject.GetComponent<TextMesh>(); 
	}
	
	// Update is called once per frame
	void Update () {
		updc ++;
		if (updc > updint) {
			updc = 0;
			currentscore = Random.Range (currentscore - 2, currentscore + 2);
			if (currentscore < 50) {
				currentscore = 50;
			}
			if (currentscore > 170) {
				currentscore = 170;
			}
			txt.text = currentscore.ToString ("F0") + "BPM";  
		}
		//currentscore = PlayerPrefs.GetInt("TOTALSCORE"); 
		//PlayerPrefs.SetInt("SHOWSTARTSCORE",currentscore); 
	}
}
