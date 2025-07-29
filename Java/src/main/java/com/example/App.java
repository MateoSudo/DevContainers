package com.example;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

/**
 * Sample JavaFX Application
 * This is a simple JavaFX application that demonstrates basic UI components.
 */
public class App extends Application {

    @Override
    public void start(Stage primaryStage) {
        // Create the main window
        primaryStage.setTitle("JavaFX Sample Application");

        // Create UI components
        Label titleLabel = new Label("Welcome to JavaFX!");
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

        Label nameLabel = new Label("Enter your name:");
        TextField nameField = new TextField();
        nameField.setPromptText("Your name here");

        Button greetButton = new Button("Greet");
        Button clearButton = new Button("Clear");

        Label resultLabel = new Label("");
        resultLabel.setStyle("-fx-font-size: 16px;");

        // Create layout
        VBox root = new VBox(10);
        root.setAlignment(Pos.CENTER);
        root.setPadding(new Insets(20));

        HBox buttonBox = new HBox(10);
        buttonBox.setAlignment(Pos.CENTER);
        buttonBox.getChildren().addAll(greetButton, clearButton);

        root.getChildren().addAll(
                titleLabel,
                nameLabel,
                nameField,
                buttonBox,
                resultLabel);

        // Add event handlers
        greetButton.setOnAction(e -> {
            String name = nameField.getText().trim();
            if (!name.isEmpty()) {
                resultLabel.setText("Hello, " + name + "! Welcome to JavaFX!");
                resultLabel.setStyle("-fx-font-size: 16px; -fx-text-fill: green;");
            } else {
                resultLabel.setText("Please enter a name!");
                resultLabel.setStyle("-fx-font-size: 16px; -fx-text-fill: red;");
            }
        });

        clearButton.setOnAction(e -> {
            nameField.clear();
            resultLabel.setText("");
        });

        // Create scene and show stage
        Scene scene = new Scene(root, 400, 300);
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}