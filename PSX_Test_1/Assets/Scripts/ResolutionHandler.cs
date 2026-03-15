using UnityEngine;
using UnityEngine.UI;

public class ResolutionHandler : MonoBehaviour
{
    [SerializeField] Camera _cam = null;
    [SerializeField] RawImage _rawImage = null;
    [SerializeField] RenderTexture _renderTexture = null;

    [ContextMenu("ToggleRender()")]
    public void ToggleRender()
    {
        _cam.targetTexture = _cam.targetTexture == null ? _renderTexture : null;
        _rawImage.gameObject.SetActive(!_rawImage.gameObject.activeSelf);
    }
}
