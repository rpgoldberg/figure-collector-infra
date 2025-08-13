const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

// Create Express app
const createApp = (versionData) => {
  const app = express();

  // Middleware
  app.use(cors());
  app.use(express.json());

  // Health check endpoints
  app.get('/', (req, res) => {
    res.json({ 
      status: 'healthy', 
      service: 'version-service',
      timestamp: new Date().toISOString()
    });
  });

  app.get('/health', (req, res) => {
    res.json({ 
      status: 'healthy', 
      service: 'version-service',
      timestamp: new Date().toISOString(),
      versionData: versionData ? 'loaded' : 'missing'
    });
  });

  // Get app version and release date
  app.get('/app-version', (req, res) => {
    if (!versionData || !versionData.application) {
      return res.status(500).json({ error: 'Version data not available' });
    }
    
    res.json({
      name: versionData.application.name,
      version: versionData.application.version,
      releaseDate: versionData.application.releaseDate,
      description: versionData.application.description || null
    });
  });

  // Validate service version combination
  app.get('/validate-versions', (req, res) => {
    const { backend, frontend, scraper } = req.query;
    
    if (!versionData || !versionData.compatibility) {
      return res.status(500).json({ error: 'Compatibility data not available' });
    }
    
    // Check if this combination exists in tested combinations
    const testedCombinations = versionData.compatibility.testedCombinations || [];
    const matchingCombo = testedCombinations.find(combo => 
      combo.backend === backend && 
      combo.frontend === frontend && 
      combo.scraper === scraper
    );
    
    if (matchingCombo) {
      return res.json({
        valid: true,
        status: 'tested',
        verified: matchingCombo.verified,
        message: 'This service combination has been tested and verified'
      });
    }
    
    // Check individual service versions against expected ranges
    const dependencies = versionData.dependencies || {};
    const warnings = [];
    
    // Check if versions meet dependency requirements (simplified semver check)
    if (dependencies.backend && dependencies.backend.scraper) {
      const requiredScraperVersion = dependencies.backend.scraper.replace('^', '');
      if (scraper !== requiredScraperVersion) {
        warnings.push(`Backend expects scraper ${dependencies.backend.scraper}, got ${scraper}`);
      }
    }
    
    if (dependencies.frontend && dependencies.frontend.backend) {
      const requiredBackendVersion = dependencies.frontend.backend.replace('^', '');
      if (backend !== requiredBackendVersion) {
        warnings.push(`Frontend expects backend ${dependencies.frontend.backend}, got ${backend}`);
      }
    }
    
    // When no tested combinations and no warnings, return compatible
    const status = testedCombinations.length === 0 && warnings.length === 0 
      ? 'compatible'
      : (warnings.length > 0 ? 'warning' : 'tested');

    res.json({
      valid: warnings.length === 0,
      status: status,
      warnings: warnings,
      message: status === 'compatible' 
        ? 'Service versions appear compatible but untested'
        : (status === 'warning'
          ? 'Service versions may have compatibility issues'
          : 'Service versions have been tested and verified')
    });
  });

  // Get all version info (for debugging)
  app.get('/version-info', (req, res) => {
    res.json(versionData);
  });

  return app;
};

// Load version data
const loadVersionData = (versionPath = null) => {
  const actualPath = versionPath || path.join(__dirname, './version.json');
  
  try {
    const data = JSON.parse(fs.readFileSync(actualPath, 'utf8'));
    if (!process.env.NODE_ENV || process.env.NODE_ENV !== 'test') {
      console.log('Loaded version data:', data.application);
    }
    return data;
  } catch (error) {
    if (!process.env.NODE_ENV || process.env.NODE_ENV !== 'test') {
      console.error('Failed to load version.json:', error.message);
      process.exit(1);
    }
    throw error;
  }
};

module.exports = { createApp, loadVersionData };