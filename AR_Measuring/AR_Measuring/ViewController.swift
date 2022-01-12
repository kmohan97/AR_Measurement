//
//  ViewController.swift
//  AR_Measuring
//
//  Created by Mohan on 12/01/22.
//

import UIKit
import ARKit


class ViewController: UIViewController,ARSCNViewDelegate {

	let sceneView: ARSCNView = {
		let p = ARSCNView()
		p.translatesAutoresizingMaskIntoConstraints = false
//		p.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
		p.showsStatistics = true
		return p
	}()
	
	let centerPoint: UILabel = {
		let p = UILabel()
		p.translatesAutoresizingMaskIntoConstraints = false
		p.textColor = .red
		return p
	}()
	
	let resetButton: UIButton = {
		let p = UIButton()
		p.translatesAutoresizingMaskIntoConstraints = false
		p.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
		p.layer.borderWidth = 1
		p.layer.cornerRadius = 2
		p.layer.borderColor = UIColor.black.cgColor
		p.setTitle(" Reset ", for: .normal)
		p.isHidden = true
		p.backgroundColor = .gray
		return p
	}()
	
	let displayLabel: UILabel = {
		let p = UILabel()
		p.translatesAutoresizingMaskIntoConstraints = false
		p.textColor = UIColor.white
		p.numberOfLines = 0
		p.textAlignment = .center
		p.backgroundColor = .clear
		return p
	}()
	
	let config = ARWorldTrackingConfiguration()
	
	var points : [SCNVector3] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sceneView.delegate = self
		view.addSubview(sceneView)
		sceneView.addSubview(centerPoint)
		sceneView.addSubview(displayLabel)
		sceneView.addSubview(resetButton)
		NSLayoutConstraint.activate([
			sceneView.topAnchor.constraint(equalTo: view.topAnchor),
			sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			centerPoint.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
			centerPoint.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor),
			
			displayLabel.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 50),
			displayLabel.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor,constant: 100),
			displayLabel.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -100),
			
			resetButton.topAnchor.constraint(equalTo: displayLabel.bottomAnchor),
			resetButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor)
		])
		
		
		
		let tap = UITapGestureRecognizer()
		tap.addTarget(self, action: #selector(handleTap))
		sceneView.addGestureRecognizer(tap)
		config.planeDetection = .horizontal
		sceneView.session.run(config)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		centerPoint.text = "+"
		displayLabel.text = "Move to the starting point and tap on the screen"
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard anchor is ARPlaneAnchor else {return}
		print("Added plane")
	}
	
	@objc func resetButtonTapped() {
		resetButton.isHidden = true
		displayLabel.text = "Move to the starting point and tap on the screen"
		sceneView.session.pause()
		sceneView.scene.rootNode.enumerateChildNodes { childNode, _ in
			childNode.removeFromParentNode()
		}
		points.removeAll()
		sceneView.session.run(config, options: .removeExistingAnchors)
	}
	
	@objc func handleTap(_ sender: UITapGestureRecognizer) {
		let area = sceneView
		let tappedCoord = area.center
		let hitTest = area.hitTest(tappedCoord, types: .featurePoint)
		if let hit = hitTest.first {
			addObject(hit: hit)
			print("Tapped")
		}
	}
	
	func addObject(hit: ARHitTestResult) {
		
		let position = SCNVector3(x: hit.worldTransform.columns.3.x, y: hit.worldTransform.columns.3.y, z: hit.worldTransform.columns.3.z)
		
		
		let node = SCNNode()
		
		let box = SCNSphere(radius: 0.002)
		box.firstMaterial?.diffuse.contents = UIColor.green
		
		node.geometry = box
		node.position = position
		if points.count <= 2 {
			sceneView.scene.rootNode.addChildNode(node)
		}
		points.append(position)
		if points.count == 2 {
			let first = points.first
			let second = points.last
			
			let x = second!.x - first!.x
			let y = second!.y - first!.y
			let z = second!.z - first!.z
			
			let dist = sqrt(x * x + y * y + z * z)
			print(dist, "  Distance")
			let positionToDisplay = SCNVector3((second!.x+first!.x)/2, (first!.y + second!.y)/2, (first!.z + second!.z)/2)
			displaySize(positionToDisplay,dist)
		}
		if points.count == 1 {
			displayLabel.text = "Move the pointer to the end point and tap again"
		}
	}
	
	func displaySize(_ position: SCNVector3, _ dist: Float) {
		let node = SCNNode()
		
		let text = SCNText(string: "\(dist) meters", extrusionDepth: 0.5)
		text.firstMaterial?.diffuse.contents = UIColor.yellow
		
		node.geometry = text
		node.position = position
		node.scale = SCNVector3(0.003, 0.003, 0.003)
		let ninetyDeg = GLKMathDegreesToRadians(-45)
		let ninetyDeg1 = GLKMathDegreesToRadians(-90)
		
		node.eulerAngles = SCNVector3(ninetyDeg,0,0)
		sceneView.scene.rootNode.addChildNode(node)
		displayLabel.attributedText = NSAttributedString(string: "Hurray!!! \n Press the reset button to measure again.")
		resetButton.isHidden = false
	}

}

