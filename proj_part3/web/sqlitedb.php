<?php # sqlite.php - creates a handle to your database.
  $dbname = "./myDatabase.db";
  try {
    $db = new PDO("sqlite:" . $dbname);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->exec("PRAGMA foreign_keys = ON;");
  } catch (PDOException $e) {
    "SQLite connection failed: " . $e->getMessage();
    exit();
  }
?>
